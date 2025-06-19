#!/usr/bin/env bash
# This script is used to update the .netrc file with the credentials using the template.
# The template is stored in the $DOTFILES/netrc/netrc.tpl file.
# Final file will be stored in $HOME/.netrc (overwrite if exists).
# The credentials are all in onepassword so require the onepassword cli to be installed.

install() {
    required op
    eval $(op signin)
    op inject -i "$DOTFILES/netrc/netrc.tpl" -o "$HOME/.netrc" -f
}

install "$@"