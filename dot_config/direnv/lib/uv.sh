# direnv stdlib extension: uv (Python project + virtualenv manager)
#
# Usage in .envrc:
#   use uv                   # activate .venv, create via uv if missing
#   use uv 3.12              # create .venv with a specific Python version
#   layout uv                # alias — matches direnv stdlib layout python
#
# No-op (with warning) when `uv` is not on PATH.

use_uv() {
  if ! has uv; then
    log_status "uv not on PATH — skipping use_uv"
    return 0
  fi

  local python_version="${1:-}"
  local venv="${2:-.venv}"

  if [[ ! -d "${venv}" ]]; then
    log_status "uv: creating ${venv}${python_version:+ (python ${python_version})}"
    if [[ -n "${python_version}" ]]; then
      uv venv "${venv}" --python "${python_version}" >&2 || {
        log_error "uv venv --python ${python_version} failed"
        return 1
      }
    else
      uv venv "${venv}" >&2 || {
        log_error "uv venv failed"
        return 1
      }
    fi
  fi

  VIRTUAL_ENV="$(cd "${venv}" && pwd)"
  export VIRTUAL_ENV
  PATH_add "${VIRTUAL_ENV}/bin"
  log_status "uv: activated ${venv}"

  watch_file pyproject.toml uv.lock requirements.txt requirements-dev.txt .python-version
}

layout_uv() {
  use_uv "$@"
}
