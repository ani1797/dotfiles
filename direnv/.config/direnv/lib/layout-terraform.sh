# layout-terraform.sh - Terraform version management for direnv
# Auto-selects terraform version based on .terraform-version or required_version

# Usage in .envrc:
#   layout terraform
#
# This will:
# 1. Check for tfenv and auto-select version from .terraform-version
# 2. Set TF_DATA_DIR for project-local terraform state
# 3. Set TF_PLUGIN_CACHE_DIR for shared plugin caching
layout_terraform() {
    # Use tfenv if available and .terraform-version exists
    if command -v tfenv >/dev/null 2>&1; then
        if [[ -f .terraform-version ]]; then
            local tf_version
            tf_version=$(cat .terraform-version)
            log_status "Using Terraform version: $tf_version (via tfenv)"
            tfenv use "$tf_version" 2>/dev/null || tfenv install "$tf_version"
        fi
    fi

    # Set up plugin cache to avoid re-downloading providers
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/terraform/plugin-cache"
    mkdir -p "$cache_dir"
    export TF_PLUGIN_CACHE_DIR="$cache_dir"
    log_status "Terraform plugin cache: $TF_PLUGIN_CACHE_DIR"
}

# Standalone function for use in .envrc
# Usage: use tfenv
use_tfenv() {
    layout_terraform
}
