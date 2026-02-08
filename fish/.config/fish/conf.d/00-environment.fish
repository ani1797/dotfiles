# ~/.config/fish/conf.d/00-environment.fish
# Environment setup - must load first

# Add user binary directories to PATH
fish_add_path $HOME/.local/bin $HOME/bin

# Set default editor (prefer nvim, fallback to vim)
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
else
    set -gx EDITOR vim
    set -gx VISUAL vim
end

# XDG Base Directory specification
set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_CACHE_HOME; or set -gx XDG_CACHE_HOME $HOME/.cache
set -q XDG_DATA_HOME; or set -gx XDG_DATA_HOME $HOME/.local/share
