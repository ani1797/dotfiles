# ~/.config/fish/conf.d/cachyos.fish
# CachyOS-specific configuration - loads only on CachyOS

if test -f /etc/cachyos-release
    and test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end
