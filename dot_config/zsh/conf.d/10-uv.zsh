# uv and uvx shell completions
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi
if command -v uvx >/dev/null 2>&1; then
  eval "$(uvx --generate-shell-completion zsh)"
fi
