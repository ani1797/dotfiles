# ==============================================================================
# LAYOUT PRECOMMIT - Pre-commit hooks integration
# ==============================================================================
# Auto-installs pre-commit hooks when entering directory
# Usage in .envrc: layout precommit

layout_precommit() {
    if ! command -v pre-commit >/dev/null 2>&1; then
        log_error "pre-commit not found. Install with: pip install pre-commit"
        return 1
    fi

    if [[ -f .pre-commit-config.yaml ]]; then
        # Check if hooks are installed by looking for the hook directory
        if [[ ! -f .git/hooks/pre-commit ]] || \
           ! grep -q "pre-commit" .git/hooks/pre-commit 2>/dev/null; then
            log_status "Installing pre-commit hooks..."
            pre-commit install --install-hooks 2>/dev/null
            log_status "Pre-commit hooks installed"
        else
            log_status "Pre-commit hooks already installed"
        fi
    fi
}

use_precommit() {
    layout_precommit
}
