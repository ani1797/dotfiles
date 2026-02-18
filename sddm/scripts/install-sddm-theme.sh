#!/usr/bin/env bash
# Install the Tokyo Night Minimal SDDM theme
# Must be run with sudo

set -euo pipefail

THEME_NAME="tokyonight-minimal"
THEME_SRC="$(dirname "$(dirname "$(readlink -f "$0")")")/theme/${THEME_NAME}"
THEME_DEST="/usr/share/sddm/themes/${THEME_NAME}"

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root (sudo)."
    exit 1
fi

echo "Installing SDDM theme: ${THEME_NAME}"
echo "  From: ${THEME_SRC}"
echo "  To:   ${THEME_DEST}"

# Copy theme files
rm -rf "${THEME_DEST}"
cp -r "${THEME_SRC}" "${THEME_DEST}"

# Configure SDDM to use the theme
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf << EOF
[Theme]
Current=${THEME_NAME}

[General]
InputMethod=
EOF

echo "Done. SDDM will use ${THEME_NAME} on next login."
