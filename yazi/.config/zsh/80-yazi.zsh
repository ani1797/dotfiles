# Guard against double-sourcing
[[ -n "${__ZSH_YAZI_LOADED+x}" ]] && return
__ZSH_YAZI_LOADED=1

# ~/.config/zsh/80-yazi.zsh
# Yazi shell wrapper — cd to last directory on exit
# Use `y` to launch; `q` to quit and cd, `Q` to quit without cd
command -v yazi &>/dev/null || return 0

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
