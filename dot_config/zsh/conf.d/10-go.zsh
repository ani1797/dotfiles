# Go environment — GOPATH, GOBIN, PATH
if command -v go >/dev/null 2>&1; then
  export GOPATH="${GOPATH:-${HOME}/go}"
  export GOBIN="${GOPATH}/bin"
  path=("${GOBIN}" $path)
fi
