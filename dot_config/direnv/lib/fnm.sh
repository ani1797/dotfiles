# direnv stdlib extension: fnm (Fast Node Manager) integration
# Usage in .envrc:
#   use fnm            — use version from .nvmrc or .node-version
#   use fnm 20         — use specific Node.js major version

use_fnm() {
  local node_version="${1:-}"

  if has fnm; then
    if [[ -z "${node_version}" ]]; then
      # Read from .nvmrc or .node-version if present
      if [[ -f .nvmrc ]]; then
        node_version=$(cat .nvmrc)
      elif [[ -f .node-version ]]; then
        node_version=$(cat .node-version)
      fi
    fi

    if [[ -n "${node_version}" ]]; then
      eval "$(fnm env --shell bash --node-version "${node_version}" 2>/dev/null)"
      log_status "Node.js ${node_version} (fnm)"
    else
      eval "$(fnm env --shell bash --use-on-cd 2>/dev/null)"
      log_status "Node.js $(node --version 2>/dev/null) (fnm default)"
    fi
  else
    log_error "fnm not found — install it from https://github.com/Schniz/fnm"
  fi

  watch_file .nvmrc .node-version
}
