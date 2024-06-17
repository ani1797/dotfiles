#!/usr/bin/env bash

set -e

required "git"
required "op"

eval "$(op signin --account "$OP_ACCOUNT")"

if [ ! -d "$HOME/.config/git" ]; then
  mkdir -p "$HOME/.config/git"
fi

if [ ! -d "$HOME/.ssh/keys" ]; then
  mkdir -p "$HOME/.ssh/keys"
fi

setup_profile() {
    local profile=$1
    # shellcheck disable=SC2155
    local pf=$(echo "$profile" | tr '[:upper:]' '[:lower:]')
    if [ ! -f "$HOME/.config/git/$pf.gitconfig" ]; then
      op inject -i "$DOTFILES/git/config/$pf.tpl" -o "$HOME/.config/git/$pf.gitconfig.txt"
    fi

    if [ ! -f "$HOME/.ssh/keys/${pf}_rsa" ]; then
      op read "op://Development/$profile/private key?ssh-format=openssh" | tr -d '\r' | tee "$HOME/.ssh/keys/${pf}_rsa" > /dev/null
      chmod 400 "$HOME/.ssh/keys/${pf}_rsa"
    fi

    if [ ! -f "$HOME/.ssh/keys/${pf}_rsa.pub" ]; then
      op read "op://Development/$profile/public key" | tr -d '\r' | tee "$HOME/.ssh/keys/${pf}_rsa.pub" > /dev/null
    fi
}

setup_profile "Personal"
setup_profile "Work"