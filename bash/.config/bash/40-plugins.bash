# ~/.config/bash/40-plugins.bash
# Bash plugins and completions

# FZF integration - check common locations
if [[ -f "/usr/share/fzf/key-bindings.bash" ]]; then
  source /usr/share/fzf/key-bindings.bash
  [[ -f "/usr/share/fzf/completion.bash" ]] && source /usr/share/fzf/completion.bash
elif [[ -f "$HOME/.fzf.bash" ]]; then
  source "$HOME/.fzf.bash"
fi

# Enable programmable completion
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

# pkgfile "command not found" handler (Arch-specific)
[[ -f "/usr/share/doc/pkgfile/command-not-found.bash" ]] && source /usr/share/doc/pkgfile/command-not-found.bash
