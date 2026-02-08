# ~/.config/fish/conf.d/30-starship.fish
# Starship prompt initialization

if type -q starship
    starship init fish | source
end
