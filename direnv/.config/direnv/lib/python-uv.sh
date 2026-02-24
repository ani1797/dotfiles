# ==============================================================================
# LAYOUT UV - Python with UV package manager
# ==============================================================================
# Sets up Python environment using UV for fast package management
# Usage in .envrc: layout uv [python-version]

layout_uv() {
    local python_version="${1:-python3}"

    if ! command -v uv >/dev/null 2>&1; then
        log_error "uv not found. Install with: curl -LsSf https://astral.sh/uv/install.sh | sh"
        return 1
    fi

    local venv_dir="$(direnv_layout_dir)/uv-venv"

    if [[ ! -d "$venv_dir" ]]; then
        log_status "Creating UV virtual environment with $python_version"
        uv venv "$venv_dir" --python "$python_version"
    fi

    export VIRTUAL_ENV="$venv_dir"
    PATH_add "$venv_dir/bin"

    log_status "UV virtual environment activated: $venv_dir"

    # Auto-install dependencies if requirements files exist
    if [[ -f pyproject.toml ]]; then
        log_status "Found pyproject.toml - run 'uv pip install .' to install"
    elif [[ -f requirements.txt ]]; then
        log_status "Found requirements.txt - run 'uv pip install -r requirements.txt' to install"
    fi
}

# Alias for consistency
use_uv() {
    layout_uv "$@"
}
