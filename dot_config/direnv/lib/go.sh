# direnv stdlib extension: Go environment
#
# Usage in .envrc:
#   use go            # export GOPATH, GOBIN, add to PATH
#   use go 1.22       # log a warning if the active Go version doesn't match
#
# No-op (with warning) when `go` is not on PATH.

use_go() {
  if ! has go; then
    log_status "go not on PATH — skipping use_go"
    return 0
  fi

  local required_version="${1:-}"
  local go_version
  go_version=$(go version | awk '{print $3}' | sed 's/go//')

  if [[ -n "${required_version}" && "${go_version}" != "${required_version}"* ]]; then
    log_status "go: active ${go_version}, project prefers ${required_version}"
  fi

  export GOPATH="${GOPATH:-${HOME}/go}"
  export GOBIN="${GOPATH}/bin"
  PATH_add "${GOBIN}"

  # Per-project GOPATH support: if .gopath exists in project root, use it
  if [[ -f .gopath ]]; then
    export GOPATH="${PWD}/$(cat .gopath)"
    export GOBIN="${GOPATH}/bin"
    PATH_add "${GOBIN}"
    log_status "go: GOPATH=${GOPATH} (local)"
  fi

  log_status "go ${go_version}: GOBIN=${GOBIN}"
  watch_file go.mod go.sum .gopath
}
