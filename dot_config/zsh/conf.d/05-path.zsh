# 05-path.zsh — prepend user-local bin directories to PATH
# Runs in the early band so all tool fragments find their binaries.

_path_prepend() {
  [[ -d "$1" ]] || return
  case ":${PATH}:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:${PATH}}" ;;
  esac
}

# Homebrew (macOS — must be first so brew-installed tools take priority)
if [[ -d /opt/homebrew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

_path_prepend "${HOME}/.local/bin"
_path_prepend "${HOME}/.cargo/bin"
_path_prepend "${HOME}/go/bin"
_path_prepend "${HOME}/.tenv/bin"

unset -f _path_prepend
export PATH
