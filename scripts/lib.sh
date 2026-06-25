#!/usr/bin/env bash
# lib.sh — shared helpers for bootstrap scripts

info()    { printf '\033[1;34m[dotfiles]\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m[dotfiles]\033[0m %s\n' "$*"; }
warn()    { printf '\033[1;33m[dotfiles]\033[0m %s\n' "$*" >&2; }
die()     { printf '\033[1;31m[dotfiles]\033[0m ERROR: %s\n' "$*" >&2; exit 1; }
