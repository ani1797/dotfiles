# ~/.config/fish/conf.d/aliases-universal.fish
# Cross-platform aliases

# Basic shortcuts
alias c='clear'
alias please='sudo'

# Git shortcuts (if git installed)
if command -v git &>/dev/null
    alias g='git'
    alias gs='git status'
    alias gd='git diff'
    alias ga='git add'
    alias gc='git commit'
    alias gp='git push'
    alias gl='git log --oneline --graph --decorate'
end

# Safety aliases
alias cp='cp -i'    # Prompt before overwrite
alias mv='mv -i'    # Prompt before overwrite
alias rm='rm -i'    # Prompt before delete

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Process management
alias ps='ps auxf'

# Network
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'
