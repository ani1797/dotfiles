# ~/.config/fish/conf.d/aliases-universal.fish
# Cross-platform aliases

# Basic shortcuts
alias c='clear'
alias please='sudo'

# Parallel build (fallback to 4 cores if nproc unavailable)
if type -q nproc
    alias make="make -j(nproc)"
    alias ninja="ninja -j(nproc)"
else
    alias make='make -j4'
    alias ninja='ninja -j4'
end
alias n='ninja'

# Safe ls aliases (if GNU coreutils available)
if ls --color=auto &>/dev/null
    alias ls='ls --color=auto'
    alias ll='ls -lh'
    alias la='ls -lha'
    alias l='ls -CF'
end

# Grep with color
alias grep='grep --color=auto'

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
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# Network
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'
