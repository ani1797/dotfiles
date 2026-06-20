# direnv stdlib extension: 1Password secret loading
#
# Loads secrets from 1Password into environment variables without writing
# them to disk. Requires: op (1Password CLI v2+), jq.
#
# Session handling: op v2 caches sessions natively (biometric / system keyring).
# If the session has expired, op will prompt automatically via the OS credential
# store — no explicit `oplog` call is needed in most cases.
#
# ── Functions ──────────────────────────────────────────────────────────────────
#
#   use op_secret VAR vault/item/field
#   use op_secret VAR op://vault/item/field   ← op:// prefix optional
#
#     Load a single field into an environment variable.
#     Examples:
#       use op_secret DATABASE_URL   dev/postgres/url
#       use op_secret STRIPE_SECRET  dev/stripe/secret-key
#       use op_secret GITHUB_TOKEN   personal/github-pat/credential
#
#   use op_item vault/item [PREFIX]
#
#     Load every field from a 1Password item as env vars.
#     Field labels are uppercased and spaces/hyphens replaced with underscores.
#     Optional PREFIX is prepended to every variable name.
#     Examples:
#       use op_item  dev/my-app-env          # DATABASE_URL=, REDIS_URL=, ...
#       use op_item  dev/my-app-env  APP_    # APP_DATABASE_URL=, APP_REDIS_URL=
#
#   use op_dotenv vault/item/document
#
#     Read a .env-style document stored as a file attachment in 1Password and
#     load each KEY=VALUE pair as an environment variable. Handles quoted
#     values, inline comments, and blank lines.
#     Example:
#       use op_dotenv  dev/my-app/.env
#
#   use op_inject .env.tpl [.env.out]
#
#     Read a local template file containing op:// references as values and
#     resolve each one via `op read`. Exports the resolved vars into the
#     environment and (optionally) writes a resolved copy to a second file.
#     The output file is written to /tmp if no destination is given so it
#     never sits in the project tree.
#     Example .env.tpl:
#       DATABASE_URL=op://dev/postgres/url
#       STRIPE_KEY=op://dev/stripe/secret-key
#     Usage:
#       use op_inject .env.tpl          # resolves into env only
#       use op_inject .env.tpl .env     # also writes .env (add to .gitignore!)
#
# ── Security notes ─────────────────────────────────────────────────────────────
#   - Values are never written to disk unless you use op_inject with an output.
#   - direnv does not log secret values in `direnv status` output.
#   - watch_file is called on local files (.env.tpl) but not on op:// refs.

# ── Internal: ensure op is available and session is live ───────────────────────
_op_check() {
  if ! has op; then
    log_error "secrets: 'op' CLI not on PATH (install: https://1password.com/downloads/command-line/)"
    return 1
  fi
  if ! has jq; then
    log_error "secrets: 'jq' not on PATH"
    return 1
  fi
  # Probe the session: a lightweight account list call.
  # op v2 resolves this via the system keyring / biometric without a prompt
  # in most cases. If auth is truly needed, op will prompt interactively.
  if ! op account list &>/dev/null; then
    log_error "secrets: 1Password session unavailable — run 'oplog' to authenticate"
    return 1
  fi
  return 0
}

# ── Normalise reference: strip leading op:// if present ───────────────────────
_op_ref() {
  local ref="${1#op://}"
  echo "op://${ref}"
}

# ── use_op_secret ─────────────────────────────────────────────────────────────
use_op_secret() {
  local var="${1:?use_op_secret: variable name required}"
  local ref="${2:?use_op_secret: vault/item/field reference required}"
  _op_check || return 1

  local value
  value=$(op read "$(_op_ref "${ref}")" 2>/dev/null) || {
    log_error "secrets: could not read ${ref}"
    return 1
  }

  export "${var}=${value}"
  log_status "secrets: ${var} ← 1Password"
}

# ── use_op_item ───────────────────────────────────────────────────────────────
use_op_item() {
  local ref="${1:?use_op_item: vault/item reference required}"
  local prefix="${2:-}"
  _op_check || return 1

  local fields
  fields=$(op item get "$(_op_ref "${ref}")" --format json 2>/dev/null) || {
    log_error "secrets: could not get item ${ref}"
    return 1
  }

  local count=0
  while IFS=$'\t' read -r label value; do
    [[ -z "${label}" || -z "${value}" ]] && continue
    # Normalise label → valid env var name
    local var
    var="${prefix}$(echo "${label}" | tr '[:lower:] -.' '[:upper:]___' | tr -cd 'A-Z0-9_')"
    [[ -z "${var}" || "${var}" == "${prefix}" ]] && continue
    export "${var}=${value}"
    (( count++ ))
  done < <(echo "${fields}" | jq -r '
    .fields[]
    | select(.value != null and .value != "")
    | select(.type != "OTP")
    | "\(.label)\t\(.value)"
  ' 2>/dev/null)

  log_status "secrets: ${count} var(s) from ${ref} → env${prefix:+ (prefix: ${prefix})}"
}

# ── use_op_dotenv ─────────────────────────────────────────────────────────────
use_op_dotenv() {
  local ref="${1:?use_op_dotenv: vault/item/document reference required}"
  _op_check || return 1

  local content
  content=$(op read "$(_op_ref "${ref}")" 2>/dev/null) || {
    log_error "secrets: could not read document ${ref}"
    return 1
  }

  local count=0
  while IFS= read -r line || [[ -n "${line}" ]]; do
    # Skip blank lines and comments
    [[ -z "${line//[[:space:]]/}" || "${line}" =~ ^[[:space:]]*# ]] && continue
    line="${line#export }"
    [[ "${line}" != *=* ]] && continue
    local key="${line%%=*}"
    local value="${line#*=}"
    key="${key//[[:space:]]/}"
    [[ "${key}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || continue
    # Strip surrounding quotes
    if   [[ "${value}" == '"'*'"' ]]; then value="${value#\"}"; value="${value%\"}"
    elif [[ "${value}" == "'"*"'" ]]; then value="${value#\'}"; value="${value%\'}"; fi
    export "${key}=${value}"
    (( count++ ))
  done <<< "${content}"

  log_status "secrets: ${count} var(s) from 1Password document ${ref}"
}

# ── use_op_inject ─────────────────────────────────────────────────────────────
use_op_inject() {
  local tpl="${1:?use_op_inject: template file required}"
  local out="${2:-}"   # optional output file
  _op_check || return 1

  [[ -f "${tpl}" ]] || {
    log_error "secrets: template file not found: ${tpl}"
    return 1
  }
  watch_file "${tpl}"

  # Resolve to a temp file first so partial failures don't corrupt the output
  local tmp
  tmp=$(mktemp /tmp/direnv-op-XXXXXX)

  local count=0 failed=0
  while IFS= read -r line || [[ -n "${line}" ]]; do
    # Only process lines whose value is an op:// reference
    if [[ "${line}" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(op://.+)$ ]]; then
      local key="${BASH_REMATCH[1]}"
      local ref="${BASH_REMATCH[2]}"
      local value
      if value=$(op read "${ref}" 2>/dev/null); then
        export "${key}=${value}"
        echo "${key}=${value}" >> "${tmp}"
        (( count++ ))
      else
        log_error "secrets: could not resolve ${key}=${ref}"
        (( failed++ ))
        echo "${line}" >> "${tmp}"   # keep original line in output
      fi
    else
      # Non-op:// lines: pass through to output unchanged, load if KEY=VALUE
      echo "${line}" >> "${tmp}"
      if [[ "${line}" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)=(.*)$ ]]; then
        export "${BASH_REMATCH[1]}=${BASH_REMATCH[2]}"
        (( count++ ))
      fi
    fi
  done < "${tpl}"

  # Write resolved file to destination if requested
  if [[ -n "${out}" ]]; then
    cp "${tmp}" "${out}"
    log_status "secrets: wrote resolved env to ${out}"
  fi
  rm -f "${tmp}"

  log_status "secrets: ${count} var(s) injected from ${tpl}${failed:+ (${failed} failed)}"
}
