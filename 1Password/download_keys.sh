#!/usr/bin/env zsh

set -euo pipefail

download() {
    required op
    local vault=$1
    local download_dir=$2

    local items=$(op item list --categories "SSH Key" --vault "$vault" --format json | jq -r '.[].id')
    for item in $items; do
        local name=$(op item get "$item" --vault "$vault" --format json | jq -r '.title')
        local private_key=$(op read "op://$vault/$item/private_key?ssh-format=openssh" | tr -d '\r')
        local public_key=$(op read "op://$vault/$item/public_key" | tr -d '\r')
        local key_type=$(op read "op://$vault/$item/key_type")
        # Save the private key to a file
        echo "$private_key" >"${download_dir}/id_${key_type}"
        echo "$public_key" >"${download_dir}/id_${key_type}.pub"
        chmod 600 "${download_dir}/id_${key_type}"
        chmod 644 "${download_dir}/id_${key_type}.pub"
        echo "Downloaded $name to ${download_dir}/id_${key_type}"
    done
}

download "${1:-Private}" "${2:-$HOME/.ssh}"