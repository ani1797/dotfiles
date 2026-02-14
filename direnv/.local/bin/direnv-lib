#!/usr/bin/env bash
# direnv-lib - Shared library for direnv init scripts
# Source this file; do not execute directly.

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Output helpers
info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*"; }

# Check that direnv is installed; exit 1 if not.
check_direnv() {
    if ! command -v direnv >/dev/null 2>&1; then
        error "direnv not installed"
        exit 1
    fi
}

# Prompt the user when .envrc already exists.
# Sets ENVRC_ACTION to "overwrite", "append", or "cancel".
handle_existing_envrc() {
    ENVRC_ACTION="overwrite"
    if [[ -f .envrc ]]; then
        warn ".envrc already exists in current directory"
        info "Current contents:"
        cat .envrc
        echo
        read -p "[O]verwrite / [A]ppend / [C]ancel? " -n 1 -r
        echo
        case "$REPLY" in
            [Oo]) ENVRC_ACTION="overwrite" ;;
            [Aa]) ENVRC_ACTION="append" ;;
            *)    info "Aborted"; exit 0 ;;
        esac
    fi
}

# Write content to .envrc based on ENVRC_ACTION, then direnv allow.
# Usage: write_envrc "content string"
write_envrc() {
    local content="$1"
    case "${ENVRC_ACTION:-overwrite}" in
        overwrite)
            printf '%s\n' "$content" > .envrc
            ;;
        append)
            printf '\n%s\n' "$content" >> .envrc
            ;;
    esac
    direnv allow
}
