# ~/.config/fish/config.fish
# Portable fish configuration
# Note: Files in conf.d/ are automatically sourced by fish

# Machine-specific overrides (not in stow)
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
