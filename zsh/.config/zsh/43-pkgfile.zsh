# Guard against double-sourcing
[[ -n "${__ZSH_PKGFILE_LOADED+x}" ]] && return
__ZSH_PKGFILE_LOADED=1

# ~/.config/zsh/43-pkgfile.zsh
# pkgfile "command not found" handler (Arch-specific)

[[ -f "/usr/share/doc/pkgfile/command-not-found.zsh" ]] && source /usr/share/doc/pkgfile/command-not-found.zsh
