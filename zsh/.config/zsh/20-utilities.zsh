# Guard against double-sourcing
[[ -n "${__ZSH_UTILS_LOADED+x}" ]] && return
__ZSH_UTILS_LOADED=1

# has - Check if a command exists
# Usage: has <command>
# Returns: 0 if command exists, 1 otherwise
has() {
    command -v "$1" >/dev/null 2>&1
}

# source_if_exists - Source a file only if it exists
# Usage: source_if_exists <file>
source_if_exists() {
    [[ -f "$1" ]] && source "$1"
}

# log_info - Print an info message in blue
# Usage: log_info "message"
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $*"
}

# log_error - Print an error message in red
# Usage: log_error "message"
log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $*" >&2
}

# log_success - Print a success message in green
# Usage: log_success "message"
log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $*"
}

# log_warn - Print a warning message in yellow
# Usage: log_warn "message"
log_warn() {
    echo -e "\033[0;33m[WARN]\033[0m $*"
}

# extract - Extract various archive formats
# Usage: extract <archive-file>
extract() {
    if [[ ! -f "$1" ]]; then
        log_error "File not found: $1"
        return 1
    fi

    case "$1" in
        *.tar.bz2|*.tbz2) tar xjf "$1" ;;
        *.tar.gz|*.tgz)   tar xzf "$1" ;;
        *.tar.xz|*.txz)   tar xJf "$1" ;;
        *.tar.zst)        tar --zstd -xf "$1" ;;
        *.tar)            tar xf "$1" ;;
        *.bz2)            bunzip2 "$1" ;;
        *.gz)             gunzip "$1" ;;
        *.xz)             unxz "$1" ;;
        *.zip)            unzip "$1" ;;
        *.rar)            unrar x "$1" ;;
        *.7z)             7z x "$1" ;;
        *.Z)              uncompress "$1" ;;
        *.deb)            ar x "$1" ;;
        *.rpm)            rpm2cpio "$1" | cpio -idmv ;;
        *)
            log_error "Unknown archive format: $1"
            return 1
            ;;
    esac
}
