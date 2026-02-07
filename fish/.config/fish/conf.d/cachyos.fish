# ~/.config/fish/conf.d/cachyos.fish
# CachyOS-specific configuration - loads only on CachyOS

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    and grep -q "ID=cachyos" /etc/os-release 2>/dev/null
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end
