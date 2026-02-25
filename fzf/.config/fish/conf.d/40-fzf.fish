# Guard against double-sourcing
if set -q __FISH_FZF_LOADED
    exit 0
end
set -g __FISH_FZF_LOADED 1

# ~/.config/fish/conf.d/40-fzf.fish
# FZF integration — keybindings and Tokyo Night theme

# Check if fzf is available
if not type -q fzf
    exit 0
end

# Tokyo Night color scheme (matching starship theme)
set -gx FZF_DEFAULT_OPTS "
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --border --height=40% --layout=reverse
  --preview-window=right:60%:wrap"

# Configure fzf keybindings (Fish native)
if type -q fzf_configure_bindings
    # Use fzf.fish plugin if available
    fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs
else
    # Fallback: source system keybindings if available
    if test -f /usr/share/fish/vendor_functions.d/fzf_key_bindings.fish
        source /usr/share/fish/vendor_functions.d/fzf_key_bindings.fish
        fzf_key_bindings
    end
end
