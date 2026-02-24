# Guard against double-sourcing
[[ -n "${__BASH_PKGFILE_LOADED+x}" ]] && return
__BASH_PKGFILE_LOADED=1

# ~/.config/bash/42-pkgfile.bash
# pkgfile "command not found" handler (Arch-specific)

[[ -f "/usr/share/doc/pkgfile/command-not-found.bash" ]] && source /usr/share/doc/pkgfile/command-not-found.bash
