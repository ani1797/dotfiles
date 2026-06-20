# 10-zoxide.zsh — zoxide smart-cd
# z <query>  — jump to most-used matching directory
# zi         — interactive fuzzy selection (requires fzf)
command -v zoxide &>/dev/null || return 0
eval "$(zoxide init zsh --cmd z)"
