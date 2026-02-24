# Guard against double-sourcing
[[ -n "${__BASH_HISTORY_LOADED+x}" ]] && return
__BASH_HISTORY_LOADED=1

# ~/.config/bash/10-history.bash
# History configuration

# History file location and size
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=100000
export HISTFILESIZE=100000

# Ignore duplicates and commands starting with space
export HISTCONTROL=ignoreboth:erasedups

# Timestamp format for history
export HISTTIMEFORMAT="%F %T "

# Append to history file (don't overwrite)
shopt -s histappend

# Save multi-line commands as one entry
shopt -s cmdhist

# Re-edit failed history substitutions
shopt -s histreedit

# Verify history substitution before executing
shopt -s histverify
