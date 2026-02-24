# Guard against double-sourcing
[[ -n "${__ZSH_HISTORY_LOADED+x}" ]] && return
__ZSH_HISTORY_LOADED=1

# ~/.config/zsh/10-history.zsh
# History configuration - works on all zsh installs

# History file location and size
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=100000

# History behavior options
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_IGNORE_DUPS       # Ignore duplicate commands
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries from history
setopt HIST_FIND_NO_DUPS      # Don't display duplicates when searching
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from history
setopt HIST_VERIFY            # Show command with history expansion before running
setopt SHARE_HISTORY          # Share history across all sessions
setopt APPEND_HISTORY         # Append to history file (not overwrite)
setopt INC_APPEND_HISTORY     # Write to history file immediately
setopt EXTENDED_HISTORY        # Record timestamp and duration in history
