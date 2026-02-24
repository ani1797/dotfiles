# ==============================================================================
# LAYOUT RUST - Rust project environment
# ==============================================================================
# Sets up Rust project environment with cargo
# Usage in .envrc: layout rust

layout_rust() {
    if ! command -v cargo >/dev/null 2>&1; then
        log_error "cargo not found. Install Rust: https://rustup.rs/"
        return 1
    fi

    # Add cargo bin to PATH
    PATH_add "$HOME/.cargo/bin"

    # Set CARGO_TARGET_DIR to project-local directory to avoid conflicts
    local cargo_target="$(direnv_layout_dir)/cargo-target"
    mkdir -p "$cargo_target"
    export CARGO_TARGET_DIR="$cargo_target"

    log_status "Rust environment activated (CARGO_TARGET_DIR=$cargo_target)"
}

use_rust() {
    layout_rust
}
