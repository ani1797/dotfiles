#!/usr/bin/env sh

has() {
    command -v "$1" 1>/dev/null 2>&1
}

required() {
    cmd=$1
    if ! has $cmd; then
        echo "[ERROR] $cmd is required."
        exit 1
    fi
}

ensure_homebrew() {
    if ! has brew; then
        NONINTERACTIVE=1; /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}


required "git"
required "curl"

ensure_homebrew