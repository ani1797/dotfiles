# 90-direnv.zsh — direnv hook + helpers

if (( ${+commands[direnv]} )); then
  eval "$(direnv hook zsh)"
fi

# Show direnv status in current dir
direnv-status() {
  if [[ -f .envrc ]]; then
    direnv status
  else
    echo "No .envrc in current directory"
  fi
}
alias ds='direnv-status'
alias da='direnv allow'
alias dr='direnv reload'
