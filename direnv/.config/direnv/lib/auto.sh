# ==============================================================================
# LAYOUT AUTO - Smart environment detection and loading
# ==============================================================================
# Automatically loads .env and .oprc (1Password) files
# Usage in .envrc: layout auto

layout_auto() {
    # Load .oprc file with 1Password secrets first (if exists)
    # .oprc should use properties file format: VAR_NAME=op://vault/item/field
    if [[ -f .oprc ]]; then
        if command -v op >/dev/null 2>&1; then
            log_status "Loading secrets from .oprc via 1Password"
            # Use set -a to auto-export all variables, then eval op inject output
            set -a
            eval "$(op inject -i .oprc 2>/dev/null || cat .oprc)"
            set +a
        else
            log_error "1Password CLI (op) not found, skipping .oprc"
            log_status "Install: https://developer.1password.com/docs/cli/get-started/"
        fi
    fi

    # Load .env file if it exists
    if [[ -f .env ]]; then
        log_status "Loading .env file"
        dotenv .env
    fi

    # Auto-detect project type and suggest appropriate layout
    # (Users can uncomment the specific layout they want in their .envrc)

    if [[ -f pyproject.toml ]] || [[ -f requirements.txt ]] || [[ -f setup.py ]]; then
        log_status "Python project detected (use 'layout python' or 'layout uv' for venv)"
    elif [[ -f package.json ]]; then
        log_status "Node.js project detected (use 'layout node' for PATH setup)"
    elif [[ -f go.mod ]]; then
        log_status "Go project detected (use 'layout go' for GOPATH)"
    elif [[ -f Cargo.toml ]]; then
        log_status "Rust project detected (use 'layout rust' for cargo)"
    fi
}
