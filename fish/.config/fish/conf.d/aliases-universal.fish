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

# Directory listing (prefer eza over ls)
if type -q eza
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first --git'
    alias la='eza -la --icons --group-directories-first --git'
    alias l='eza -1 --icons'
    alias lt='eza --tree --icons --level=2'
    alias lg='eza -l --icons --git --git-ignore'
else if ls --color=auto &>/dev/null
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

# Dotfiles quick access
set -gx DOT "$HOME/.local/share/dotfiles"
alias dot='cd $DOT'

# Set a temporary environment variable in the current session
function set_env --description "Set a temporary environment variable"
    if test (count $argv) -ne 2
        echo "Usage: set_env KEY VALUE" >&2; return 1
    end
    set -gx $argv[1] $argv[2]
end
