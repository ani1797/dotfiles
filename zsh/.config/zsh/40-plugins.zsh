# ~/.config/zsh/40-plugins.zsh
# Zsh plugins - loads if available

# Syntax highlighting - try multiple common locations
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# Autosuggestions - try multiple common locations
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# History substring search - try multiple common locations
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# FZF integration - check common locations
if [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi

# pkgfile "command not found" handler (Arch-specific)
[[ -f "/usr/share/doc/pkgfile/command-not-found.zsh" ]] && source /usr/share/doc/pkgfile/command-not-found.zsh
