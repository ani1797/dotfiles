# Bash Configuration Module

Basic bash shell configuration for interactive shells.

## Features

- **Minimal configuration** - Essential settings only
- **Color support** - Colorized ls and grep output
- **PATH configuration** - Adds ~/bin to PATH
- **Direnv integration** - Automatic environment loading (if direnv installed)

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

This deploys:
- `~/.bashrc` - Bash configuration file

## Configuration

The `.bashrc` file includes:

### Interactive Shell Check
```bash
[[ $- != *i* ]] && return
```
Exits early if not running interactively (prevents errors in non-interactive contexts).

### PATH Configuration
```bash
export PATH="$HOME/bin:$PATH"
```
Adds `~/bin` to the beginning of PATH for user scripts.

### Aliases
```bash
alias ls='ls --color=auto'
alias grep='grep --color=auto'
```
Enables color output for common commands.

### Prompt
```bash
PS1='[\u@\h \W]\$ '
```
Simple prompt showing: `[user@host directory]$`

### Direnv Integration
```bash
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook bash)"
fi
```
Loads direnv hook if direnv is installed, enabling automatic environment loading based on `.envrc` files.

## Machine-Specific Overrides

Bash doesn't have a built-in mechanism for local overrides in this configuration. To add machine-specific settings:

1. Add to the end of `~/.bashrc` after deployment:
   ```bash
   # Machine-specific settings
   if [[ -f ~/.bashrc.local ]]; then
       source ~/.bashrc.local
   fi
   ```

2. Create `~/.bashrc.local` (not managed by stow):
   ```bash
   # Example: work machine settings
   export HTTP_PROXY="http://proxy.example.com:8080"
   alias work-vpn="sudo openvpn /etc/openvpn/work.conf"
   ```

## Customization

### Add More Aliases

Edit `bash/.bashrc` and add aliases before the direnv integration:
```bash
alias ll='ls -lah'
alias ..='cd ..'
alias grep='grep --color=auto -i'
```

### Enhance the Prompt

Replace the PS1 line with a more informative prompt:
```bash
# Show git branch in prompt
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1='[\u@\h \W]\$(parse_git_branch)\$ '
```

### Add Functions

Add useful functions after the aliases:
```bash
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.gz) tar xzf "$1" ;;
            *.zip) unzip "$1" ;;
            *.tar.bz2) tar xjf "$1" ;;
            *) echo "Unknown archive format" ;;
        esac
    fi
}
```

## Module Configuration

Deployed to hosts: `HOME-DESKTOP`

Module structure:
```
bash/
├── .bashrc      # Main bash configuration
└── README.md    # This file
```

## References

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [Bash Guide](https://mywiki.wooledge.org/BashGuide)
- [Direnv Documentation](https://direnv.net/)
