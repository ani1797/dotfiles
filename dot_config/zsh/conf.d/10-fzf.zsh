# 10-fzf.zsh — fzf configuration
# Requires: fzf, fd, bat, ripgrep

(( $+commands[fzf] )) || return 0

# Use fd for file listing (respects .gitignore and fd/ignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow'

# Tokyo Night color scheme
export FZF_DEFAULT_OPTS=" \
    --height=60% --layout=reverse --border=rounded --margin=0,1 \
    --prompt='   ' --pointer=' ' --marker=' ' \
    --color=bg+:#283457,bg:#1a1b26,spinner:#7dcfff,hl:#bb9af7 \
    --color=fg:#c0caf5,header:#bb9af7,info:#7aa2f7,pointer:#7dcfff \
    --color=marker:#9ece6a,fg+:#c0caf5,prompt:#7aa2f7,hl+:#bb9af7 \
    --color=border:#3b4261 \
    --bind='ctrl-d:half-page-down,ctrl-u:half-page-up' \
    --bind='ctrl-y:execute-silent(echo {+} | xclip -selection clipboard 2>/dev/null || echo {+} | pbcopy 2>/dev/null)'"

# Preview with bat for Ctrl-T (file finder)
export FZF_CTRL_T_OPTS=" \
    --preview 'bat --color=always --style=numbers --line-range=:300 {} 2>/dev/null || cat {}' \
    --preview-window 'right:50%:border-left' \
    --bind 'ctrl-/:toggle-preview'"

# Preview directory tree for Alt-C (cd)
export FZF_ALT_C_OPTS=" \
    --preview 'eza --tree --color=always --icons --level=2 {} 2>/dev/null || ls -la --color=always {}' \
    --preview-window 'right:40%:border-left'"

# Ctrl-R (history) tweaks
export FZF_CTRL_R_OPTS=" \
    --preview 'echo {}' --preview-window 'up:3:hidden:wrap' \
    --bind 'ctrl-/:toggle-preview' \
    --bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard 2>/dev/null || echo -n {2..} | pbcopy 2>/dev/null)+abort' \
    --header 'CTRL-Y: copy | CTRL-/: preview'"

# Load fzf keybindings and completion
eval "$(fzf --zsh 2>/dev/null)" || {
  # Fallback for older fzf versions
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
}

# Use fd for fzf path completion (e.g., vim **<tab>)
_fzf_compgen_path() { fd --hidden --follow . "$1"; }
_fzf_compgen_dir() { fd --type d --hidden --follow . "$1"; }
