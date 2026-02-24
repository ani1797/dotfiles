# Guard against double-sourcing using a function check
if functions -q __fish_utils_loaded
    return
end

function __fish_utils_loaded
    # Marker function to prevent double-sourcing
end

# has - Check if a command exists
# Usage: has <command>
# Returns: 0 if command exists, 1 otherwise
function has
    type -q $argv[1]
end

# source_if_exists - Source a file only if it exists
# Usage: source_if_exists <file>
function source_if_exists
    if test -f "$argv[1]"
        source "$argv[1]"
    end
end

# log_info - Print an info message in blue
# Usage: log_info "message"
function log_info
    echo -e "\033[0;34m[INFO]\033[0m $argv"
end

# log_error - Print an error message in red
# Usage: log_error "message"
function log_error
    echo -e "\033[0;31m[ERROR]\033[0m $argv" >&2
end

# log_success - Print a success message in green
# Usage: log_success "message"
function log_success
    echo -e "\033[0;32m[SUCCESS]\033[0m $argv"
end

# log_warn - Print a warning message in yellow
# Usage: log_warn "message"
function log_warn
    echo -e "\033[0;33m[WARN]\033[0m $argv"
end

# extract - Extract various archive formats
# Usage: extract <archive-file>
function extract
    if not test -f "$argv[1]"
        log_error "File not found: $argv[1]"
        return 1
    end

    switch "$argv[1]"
        case '*.tar.bz2' '*.tbz2'
            tar xjf "$argv[1]"
        case '*.tar.gz' '*.tgz'
            tar xzf "$argv[1]"
        case '*.tar.xz' '*.txz'
            tar xJf "$argv[1]"
        case '*.tar.zst'
            tar --zstd -xf "$argv[1]"
        case '*.tar'
            tar xf "$argv[1]"
        case '*.bz2'
            bunzip2 "$argv[1]"
        case '*.gz'
            gunzip "$argv[1]"
        case '*.xz'
            unxz "$argv[1]"
        case '*.zip'
            unzip "$argv[1]"
        case '*.rar'
            unrar x "$argv[1]"
        case '*.7z'
            7z x "$argv[1]"
        case '*.Z'
            uncompress "$argv[1]"
        case '*.deb'
            ar x "$argv[1]"
        case '*.rpm'
            rpm2cpio "$argv[1]" | cpio -idmv
        case '*'
            log_error "Unknown archive format: $argv[1]"
            return 1
    end
end
