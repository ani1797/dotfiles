#!/usr/bin/env bash

set -e

required "git"
required "op"

PERSONAL_CONFIG="$HOME/.config/git/.gitconfig-personal"
WORK_CONFIG="$HOME/.config/git/.gitconfig-work"

if [ ! -f "$PERSONAL_CONFIG" ] || [ ! -f "$WORK_CONFIG" ]; then
    eval "$(op signin --account "$OP_ACCOUNT")"
    op inject -i "$DOTFILES/git/config/personal.tpl" -o "$PERSONAL_CONFIG"
    op inject -i "$DOTFILES/git/config/work.tpl" -o "$WORK_CONFIG"
fi