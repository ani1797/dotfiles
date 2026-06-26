# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io). Compatible with:

- Arch Linux (and derivatives: EndeavourOS, Manjaro)
- Fedora (including Silverblue / immutable variants)
- Debian / Ubuntu (and derivatives)
- macOS (Homebrew)
- GitHub Codespaces (skips desktop configs automatically)

## Quick start

### New machine (headless)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ani1797/dotfiles/main/install.sh)
```

### New machine (desktop — includes Hyprland, Kitty, etc.)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ani1797/dotfiles/main/install.sh) --desktop
```

### After cloning
```bash
git clone https://github.com/ani1797/dotfiles ~/Projects/dotfiles
bash ~/Projects/dotfiles/install.sh            # headless
bash ~/Projects/dotfiles/install.sh --desktop   # desktop
```

### GitHub Codespaces
Set this repo as your [dotfiles repository](https://docs.github.com/en/codespaces/setting-your-user-preferences/personalizing-github-codespaces-for-your-account) in GitHub settings.
Codespaces will run `install.sh` automatically. Desktop configs (Hyprland, Kitty, etc.) are skipped.

## How it works

`install.sh` is a thin bootstrapper — it installs chezmoi and runs `chezmoi init --apply`.
All tool installation is handled by **granular chezmoi `run_onchange_before_` scripts**.
Each tool has its own script that:

1. Checks if the tool is already installed (`command -v`)
2. Installs via the native OS package manager (pacman, dnf, apt, brew)
3. Falls back to official installers or cargo where needed
4. Re-runs automatically if the install method changes

## Structure

```
dotfiles/
├── .chezmoi.toml.tmpl              # chezmoi config — prompts for name/email/hostname/monitor
├── .chezmoiignore                  # skips desktop configs in Codespaces / headless / non-Linux
├── .chezmoitemplates/
│   └── install-helper              # shared pkg_install() + logging for all install scripts
├── install.sh                      # bootstrap — installs chezmoi, runs chezmoi init --apply
│
├── run_onchange_before_00-…core    # zsh, git, curl, unzip
├── run_onchange_before_10-…bat     # syntax-highlighted cat
├── run_onchange_before_10-…delta   # git diff pager (cargo fallback)
├── run_onchange_before_10-…direnv  # per-directory env vars
├── run_onchange_before_10-…eza     # modern ls (cargo fallback)
├── run_onchange_before_10-…fzf     # fuzzy finder
├── run_onchange_before_10-…gh      # GitHub CLI (repo setup on Debian/Fedora)
├── run_onchange_before_10-…neovim  # text editor
├── run_onchange_before_10-…starship # prompt (official installer fallback)
├── run_onchange_before_10-…tmux    # terminal multiplexer
├── run_onchange_before_10-…zoxide  # smart cd (official installer fallback)
├── run_onchange_before_20-…bun     # JS runtime (official installer / brew)
├── run_onchange_before_20-…fnm     # Node version manager (official installer / brew)
├── run_onchange_before_20-…uv      # Python package manager (official installer / brew)
├── run_onchange_before_30-…zsh-plugins  # autosuggestions, syntax-highlighting, history-search
├── run_onchange_before_31-…paru    # AUR helper (Arch only)
├── run_onchange_before_90-…desktop # Hyprland + supporting tools (Linux desktop only)
│
├── dot_zshrc                       # ~/.zshrc — sources conf.d fragments
├── dot_npmrc                       # npm config
├── dot_bunfig.toml                 # bun config
├── dot_cargo/                      # cargo config
└── dot_config/
    ├── git/                        # git config, aliases, SSH signing, delta pager
    ├── zsh/conf.d/                 # modular zsh: env, tools, aliases, plugins
    ├── direnv/lib/                 # custom direnv libs: uv, fnm, rust, go, podman, secrets
    ├── nvim/                       # AstroNvim v4 config
    ├── tmux/                       # tmux config
    ├── starship.toml               # starship prompt (Catppuccin Mocha)
    ├── hypr/                       # Hyprland compositor (desktop only)
    ├── kitty/                      # Kitty terminal (desktop only)
    ├── mako/                       # Mako notifications (desktop only)
    ├── quickshell/                 # Quickshell status bar (desktop only)
    └── systemd/user/               # ssh-agent socket unit (desktop only)
```

## OS-specific files

| File | Handled by |
|---|---|
| `12-syspackage.zsh` | chezmoi template — detects Arch vs Fedora vs Debian vs macOS at apply time |
| `autostart.conf` | chezmoi template — resolves polkit path and quickshell binary name |
| `11-paru.zsh` | Arch-only (included on all, no-ops on non-Arch via `command -v paru` guard) |

## OS repos

- [ani1797/arch-dev](https://github.com/ani1797/arch-dev) — Arch Linux declarative config (aconfmgr)
- [ani1797/fedora-dev](https://github.com/ani1797/fedora-dev) — Fedora Silverblue OCI image (BlueBuild)

Both bootstrap scripts point here: `chezmoi init --apply ani1797/dotfiles`
