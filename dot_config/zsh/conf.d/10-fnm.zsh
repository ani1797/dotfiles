# activate fnm (Fast Node Manager) for interactive zsh
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
  eval "$(fnm completions --shell zsh)"
fi
