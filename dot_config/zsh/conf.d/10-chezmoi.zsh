# 10-chezmoi.zsh — chezmoi shell completion
command -v chezmoi &>/dev/null || return 0
eval "$(chezmoi completion zsh)"
