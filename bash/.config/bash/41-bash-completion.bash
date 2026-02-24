# Guard against double-sourcing
[[ -n "${__BASH_COMPLETION_LOADED+x}" ]] && return
__BASH_COMPLETION_LOADED=1

# ~/.config/bash/41-bash-completion.bash
# Enable programmable completion

if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi
