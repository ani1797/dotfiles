# direnv stdlib extension: Rust/rustup integration
# Usage in .envrc:
#   use rust             — use toolchain from rust-toolchain.toml or stable
#   use rust nightly     — use specific toolchain

use_rust() {
  local toolchain="${1:-}"

  if has rustup; then
    if [[ -z "${toolchain}" && -f rust-toolchain.toml ]]; then
      toolchain=$(grep '^channel' rust-toolchain.toml | sed 's/.*= *"\(.*\)"/\1/')
    fi
    toolchain="${toolchain:-stable}"
    PATH_add "${HOME}/.cargo/bin"
    log_status "Rust ${toolchain} (rustup)"
    watch_file rust-toolchain.toml
  else
    log_error "rustup not found — install from https://rustup.rs"
  fi
}
