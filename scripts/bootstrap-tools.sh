#!/usr/bin/env bash
# bootstrap-tools.sh — install cross-platform developer tools via official scripts
#
# Runs on all platforms. Each tool is guarded by command -v so it is only
# installed when missing (the OS-specific bootstrap may have installed it).

set -euo pipefail
source "$(dirname "$0")/lib.sh"

BIN_DIR="${HOME}/.local/bin"
mkdir -p "${BIN_DIR}"
export PATH="${BIN_DIR}:${PATH}"

# ── starship (prompt) ────────────────────────────────────────────────────────
if ! command -v starship &>/dev/null; then
  info "Installing starship…"
  curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "${BIN_DIR}"
fi

# ── uv (Python package manager) ──────────────────────────────────────────────
if ! command -v uv &>/dev/null; then
  info "Installing uv…"
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ── fnm (Node version manager) ───────────────────────────────────────────────
if ! command -v fnm &>/dev/null; then
  info "Installing fnm…"
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --install-dir "${BIN_DIR}" --skip-shell
fi

# ── bun (JavaScript runtime) ─────────────────────────────────────────────────
if ! command -v bun &>/dev/null; then
  info "Installing bun…"
  curl -fsSL https://bun.sh/install | bash -s -- --no-profile 2>/dev/null || true
fi

# ── zoxide (smart cd) ────────────────────────────────────────────────────────
if ! command -v zoxide &>/dev/null; then
  info "Installing zoxide…"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# ── eza (modern ls) ──────────────────────────────────────────────────────────
if ! command -v eza &>/dev/null; then
  if command -v cargo &>/dev/null; then
    info "Installing eza via cargo…"
    cargo install eza --locked
  else
    warn "eza: skipped — install cargo (rustup) first, then run: cargo install eza --locked"
  fi
fi

# ── delta (git pager) ────────────────────────────────────────────────────────
if ! command -v delta &>/dev/null; then
  if command -v cargo &>/dev/null; then
    info "Installing delta via cargo…"
    cargo install git-delta --locked
  else
    warn "delta: skipped — install cargo (rustup) first, then run: cargo install git-delta --locked"
  fi
fi

success "Developer tools installed."
