# 40-zsh-plugins.zsh — shell enhancement plugins
#
# Loads (in order):
#   1. zsh-autosuggestions   — fish-like inline suggestions from history
#   2. syntax highlighting   — fast-syntax-highlighting (Arch) or zsh-syntax-highlighting
#   3. history-substring-search — up/down arrow searches history
#
# Path detection: checks both Arch (/usr/share/zsh/plugins/NAME/)
# and Fedora (/usr/share/NAME/) install paths automatically.

_source_first() {
  local f
  for f in "$@"; do
    [[ -f "$f" ]] && { source "$f"; return 0; }
  done
  return 1
}

# ── 1. zsh-autosuggestions ───────────────────────────────────────────────────────
if _source_first \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh; then
  # Catppuccin Mocha surface2 colour for the ghost text
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#585b70'
  # Accept suggestion with Ctrl+Space or →
  bindkey '^ ' autosuggest-accept
  bindkey '^[[C' autosuggest-accept   # → arrow
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
fi

# ── 2. Syntax highlighting ────────────────────────────────────────────────────────
# Prefer fast-syntax-highlighting (Arch AUR), fall back to standard
_source_first \
  /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── 3. History substring search ────────────────────────────────────────────────────
# Must be sourced AFTER syntax highlighting to avoid keybind conflicts
if _source_first \
    /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh \
    /usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh; then
  # ↑/↓ arrows search history by prefix of what is already typed
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  # Also bind for tmux/screen/kitty which may send different codes
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down
  # Catppuccin Mocha colours for match highlighting
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=#a6e3a1,bold'      # green
  HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=#f38ba8,bold'  # red
fi

unset -f _source_first

# ── General keybinds ──────────────────────────────────────────────────────────────
bindkey -e   # emacs key bindings (default; Ctrl+A/E, Ctrl+R, etc.)
bindkey '^[[H'  beginning-of-line     # Home key
bindkey '^[[F'  end-of-line           # End key
bindkey '^[[3~' delete-char           # Delete key
bindkey '^H'    backward-delete-word  # Ctrl+Backspace
bindkey '^[[1;5C' forward-word        # Ctrl+→
bindkey '^[[1;5D' backward-word       # Ctrl+←
