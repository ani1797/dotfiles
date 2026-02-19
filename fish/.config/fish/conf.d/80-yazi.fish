# ~/.config/fish/conf.d/80-yazi.fish
# Yazi shell wrapper — cd to last directory on exit
# Use `y` to launch; `q` to quit and cd, `Q` to quit without cd

function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
