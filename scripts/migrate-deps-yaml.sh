#!/usr/bin/env bash
# migrate-deps-yaml.sh - Migrate deps.yaml to new format
# Adds top-level 'provides' field (extracted from script sections)

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 MODULE_DIR" >&2
    exit 1
fi
MODULE_DIR="$1"

if [[ ! -f "$MODULE_DIR/deps.yaml" ]]; then
    echo "No deps.yaml in $MODULE_DIR"
    exit 0
fi

echo "Migrating $MODULE_DIR/deps.yaml..."

# Check if already migrated (has top-level 'provides' field)
if yq -e '.provides' "$MODULE_DIR/deps.yaml" >/dev/null 2>&1; then
    echo "  Already has 'provides' field, skipping"
    exit 0
fi

# Extract provides from script section if it exists
PROVIDES=$(yq -r '.script[]?.provides // empty' "$MODULE_DIR/deps.yaml" 2>/dev/null | head -1)

if [[ -n "$PROVIDES" ]]; then
    echo "  Adding provides: $PROVIDES"
    yq -y -i --arg provides "$PROVIDES" '.provides = $provides' "$MODULE_DIR/deps.yaml"
fi

echo "  Migration complete"
