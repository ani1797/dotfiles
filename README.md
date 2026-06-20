# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io). Compatible with:

- Arch Linux (`arch-dev`)
- Fedora Silverblue (`fedora-dev`)
- GitHub Codespaces (skips desktop configs automatically)
- Any Linux machine

## Quick start

### New machine
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ani1797/dotfiles/main/install.sh)
```

### After cloning
```bash
git clone https://github.com/ani1797/dotfiles ~/Projects/dotfiles
bash ~/Projects/dotfiles/install.sh
```

### GitHub Codespaces
Set this repo as your [dotfiles repository](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account) in GitHub settings.
Codespaces will run `install.sh` automatically. Desktop configs (Hyprland, Kitty, etc.) are skipped.

## Structure

```
dotfiles/
├── .chezmoi.toml.tmpl        # chezmoi config — prompts for name/email/hostname/monitor
├── .chezmoiignore            # skips desktop configs in Codespaces / headless
├── install.sh                # bootstrap — works standalone and in Codespaces
├── dot_zshrc                 # ~/.zshrc — sources conf.d fragments
└── dot_config/
    ├── git/                  # git config, aliases, SSH signing, delta pager
    ├── zsh/conf.d/           # modular zsh: env, tools, aliases, plugins
    ├── direnv/lib/           # custom direnv libs: uv, fnm, rust, go, podman, secrets
    ├── nvim/                 # AstroNvim v4 config
    ├── tmux/                 # tmux config
    ├── starship.toml         # starship prompt (Catppuccin Mocha)
    ├── hypr/                 # Hyprland compositor (desktop only)
    ├── kitty/                # Kitty terminal (desktop only)
    ├── mako/                 # Mako notifications (desktop only)
    ├── quickshell/           # Quickshell status bar (desktop only)
    └── systemd/user/         # ssh-agent socket unit (desktop only)
```

## OS-specific files

| File | Handled by |
|---|---|
| `12-syspackage.zsh` | chezmoi template — detects Arch vs Fedora Silverblue at apply time |
| `autostart.conf` | chezmoi template — resolves polkit path and quickshell binary name |
| `11-paru.zsh` | Arch-only (included in all, no-ops on non-Arch via `command -v paru` guard) |

## OS repos

- [ani1797/arch-dev](https://github.com/ani1797/arch-dev) — Arch Linux declarative config (aconfmgr)
- [ani1797/fedora-dev](https://github.com/ani1797/fedora-dev) — Fedora Silverblue OCI image (BlueBuild)

Both bootstrap scripts point here: `chezmoi init --apply ani1797/dotfiles`
