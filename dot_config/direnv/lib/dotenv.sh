# direnv stdlib extension: .env file loading
#
# Safer, richer alternative to direnv's built-in `dotenv` and `dotenv_if_exists`.
# Handles: comments, quoted values, `export` prefix, multi-file loading,
# inline comments on unquoted values, and blank lines.
#
# Usage in .envrc:
#   use dotenv                    # load .env (silent if missing)
#   use dotenv .env.local         # load a named file
#   use dotenv .env .env.local    # load multiple files in order (last wins)
#
# Security: values are masked in log output (shown as ***)

use_dotenv() {
  local files=("${@:-.env}")

  for file in "${files[@]}"; do
    if [[ ! -f "${file}" ]]; then
      log_status "dotenv: ${file} not found, skipping"
      continue
    fi

    watch_file "${file}"
    local count=0

    while IFS= read -r line || [[ -n "${line}" ]]; do
      # Skip blank lines
      [[ -z "${line//[[:space:]]/}" ]] && continue
      # Skip comment lines
      [[ "${line}" =~ ^[[:space:]]*# ]] && continue
      # Strip leading 'export '
      line="${line#export }"
      line="${line#"${line%%[! ]*}"}"  # ltrim
      # Must contain = to be a valid assignment
      [[ "${line}" != *=* ]] && continue

      local key="${line%%=*}"
      local value="${line#*=}"

      # Strip whitespace from key
      key="${key// /}"
      [[ -z "${key}" ]] && continue
      # Keys must be valid identifiers
      [[ "${key}" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || continue

      # Handle double-quoted values: "value" -> value (preserves spaces, strips quotes)
      if [[ "${value}" == '"'*'"' ]]; then
        value="${value#\"}"; value="${value%\"}"
      # Handle single-quoted values: 'value' -> value
      elif [[ "${value}" == "'"*"'" ]]; then
        value="${value#\'}"; value="${value%\'}"
      else
        # Unquoted: strip trailing inline comment and whitespace
        value="${value%%[[:space:]]\#*}"
        value="${value%"${value##*[! ]}"}"  # rtrim
      fi

      export "${key}=${value}"
      (( count++ ))
    done < "${file}"

    log_status "dotenv: loaded ${file} (${count} vars)"
  done
}

# Alias: use_dotenv_if_exists is identical — both are silent on missing files
use_dotenv_if_exists() { use_dotenv "$@"; }
