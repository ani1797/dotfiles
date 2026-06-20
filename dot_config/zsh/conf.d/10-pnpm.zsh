# 10-pnpm.zsh — pnpm shell completion
command -v pnpm &>/dev/null || return 0
eval "$(pnpm completion zsh 2>/dev/null)"
