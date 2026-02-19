# Dotfiles Stow Module Restructure — Design

**Date:** 2026-02-19
**Status:** Approved

## Overview

Restructure the dotfiles repository to unify module management under a single `install.sh` entrypoint with a cleaner `config.yaml` schema, per-module dependency management with multi-source support, consistent shell guard patterns, and dead symlink cleanup.

## config.yaml Schema

Split into two top-level keys: `modules[]` (definitions) and `machines[]` (assignments).

```yaml
modules:
  - name: bash
    path: bash
  - name: sddm
    path: sddm
    target: /usr/share/sddm/themes   # module-level default, overrides $HOME

machines:
  - hostname: HOME-DESKTOP
    modules:
      - bash                           # string = use module defaults
      - zsh
      - name: sddm                    # object = override target
        target: /opt/custom
  - hostname: WORK-MACBOOK
    modules:
      - bash
      - zsh
```

- `modules[]` defines all available modules with `name`, `path`, optional `target` (defaults to `$HOME`)
- `machines[]` references modules by name (string) or by object with `name` + `target` override
- `config.yaml` is the sole source of truth for what gets stowed where
- Module not listed in a machine's modules list = skipped on that host

## deps.yaml Schema

Each module has its own `deps.yaml` supporting multiple install sources:

```yaml
packages:
  arch:
    - neovim
    - ripgrep
  debian:
    - neovim
    - ripgrep
  fedora:
    - neovim
    - ripgrep
  macos:
    - neovim
    - ripgrep

cargo:
  - yazi-fm
  - yazi-cli

pip:
  - neovim-remote

script:
  - url: https://starship.rs/install.sh
    args: ["--yes"]
```

- `packages` key with per-distro arrays: `arch`, `debian`, `fedora`, `macos`
- Optional `cargo`, `pip`, `script` sections for non-native installs
- `install.sh` detects the distro, picks the right key, installs missing packages
- For `cargo`/`pip`: installs if the binary isn't already present
- For `script`: downloads and runs with given args (guarded by checking if tool exists)
- Missing distro key = no packages for that platform (skipped, no error)

## install.sh Behavior

Single entrypoint that replaces both current `install.sh` and `bootstrap.sh`:

```
install.sh
├── 1. Self-bootstrap: ensure stow + yq are installed
│     └── Detect distro → install stow/yq via native pkg manager
├── 2. Read config.yaml
│     └── Match current hostname against machines[]
├── 3. For each module assigned to this machine:
│     ├── a. Read module's deps.yaml
│     ├── b. Install missing packages (native → cargo → pip → script)
│     ├── c. Backup conflicting files to ~/.dotfiles-backup/<timestamp>/
│     ├── d. Stow the module using --restow (--no-folding)
│     │     └── --restow unstows then re-stows, cleaning dead symlinks
│     └── e. Dead symlinks from removed repo files are cleaned by restow
└── 4. Summary: report what was installed, backed up, any failures
```

- `bootstrap.sh` is removed
- Idempotent: safe to run repeatedly
- Backup before stow: real files blocking symlinks move to `~/.dotfiles-backup/<timestamp>/`
- `configure-*` scripts are NOT auto-run — user runs them manually (may need elevated privileges)
- Distro detection: `/etc/os-release` for Linux, `uname` for macOS
- Package install uses `sudo` for native packages; cargo/pip run as user

## Shell Guard Pattern

Every numbered config fragment that activates/depends on a tool must guard at the top. Fail-fast if the tool isn't present.

```bash
# bash/zsh:
command -v <tool> &>/dev/null || return 0
# ... activation + completions

# fish:
command -v <tool> &>/dev/null; or return
# ... activation + completions
```

### Plugin File Breakdown

Split monolithic `40-plugins.*` into per-tool files:

```
00-environment.*     — env vars, PATH
10-history.*         — history config
30-starship.*        — prompt
40-fzf.*             — fuzzy finder (guard + activation + completions)
40-zoxide.*          — directory jumper (if used)
50-aliases-*.*       — aliases (per-category, stay in shell modules)
51-aliases-arch.*    — distro-specific (stay in shell modules)
51-aliases-debian.*
51-aliases-fedora.*
52-aliases-docker.*
52-aliases-k8s.*
52-aliases-terraform.*
60-direnv.*          — direnv hook
70-ssh-agent.*       — ssh agent
80-yazi.*            — yazi shell integration
```

Each file is self-contained: guard at top, activation below, completions included.

### Completions

Each tool's config fragment enables shell completions where available:

- Some tools generate completions dynamically (`kubectl completion bash`, `gh completion -s bash`)
- Some ship completion files at known paths
- Some bundle completions into their init command (`fzf --bash`)
- Completion setup is guarded — if the completion source doesn't exist, skip silently

## Modularity Approach

**Pragmatic soft dependencies:** Cross-module config snippets are allowed as long as they fail gracefully via the guard pattern. Shared utilities like `shell-utils` are allowed as a dependency. Modules like `wayvnc` can provide config for other tools (e.g., `.config/hypr/conf.d/wayvnc.conf`).

## Deficit Summary

### Must change

| Item | Current State | Required Change |
|------|--------------|-----------------|
| config.yaml schema | `modules[].hosts[]` (module-centric) | Split into `modules[]` + `machines[]` top-level keys |
| install.sh | Stow only, no dep install or backup | Rewrite: distro detect, dep install, backup, restow, dead symlink cleanup |
| bootstrap.sh | 700+ line separate script | Remove entirely, absorb logic into install.sh |
| yazi/deps.yaml | Missing | Create with appropriate packages |
| 80-yazi.* | No guard | Add `command -v yazi` guard (all 3 shells) |
| 70-ssh-agent.* | No guard | Add `command -v ssh-agent` guard (all 3 shells) |
| 40-plugins.* | Monolithic | Split into per-tool files with individual guards |

### Net-new work

| Item | Description |
|------|-------------|
| Shell completions | Add completion setup in each tool's config fragment where available |
| Multi-source deps | Audit all deps.yaml files, add `cargo`/`pip`/`script` sections where bootstrap.sh currently handles installs |

### No changes needed

- Module directory structure (already follows `.config/<module>` pattern)
- `.stow-local-ignore` files (present on all 26 modules)
- `configure-*` scripts (stay manual)
- Alias files (stay in shell modules)
- Soft cross-module deps (already guarded in most cases)
