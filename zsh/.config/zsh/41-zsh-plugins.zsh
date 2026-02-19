# ~/.config/zsh/41-zsh-plugins.zsh
# Zsh plugins — loads from system packages if available

# Syntax highlighting
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# Autosuggestions
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# History substring search
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done
