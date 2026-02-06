# ~/.config/zsh/10-history.zsh
# History configuration - works on all zsh installs

# History file location and size
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000

# History behavior options
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_IGNORE_DUPS       # Ignore duplicate commands
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from history
setopt HIST_VERIFY            # Show command with history expansion before running
setopt SHARE_HISTORY          # Share history across all sessions
setopt APPEND_HISTORY         # Append to history file (not overwrite)
setopt INC_APPEND_HISTORY     # Write to history file immediately
