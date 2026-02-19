# Stow Module Restructure Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure the dotfiles repo to use a split `modules[]` + `machines[]` config schema, a unified `install.sh` that handles deps/backup/stow/cleanup, consistent shell guards, and per-tool plugin files.

**Architecture:** Single `install.sh` entrypoint replaces both current `install.sh` and `bootstrap.sh`. Config schema splits module definitions from machine assignments. Shell config fragments become strictly one-file-per-tool with guards and completions.

**Tech Stack:** Bash, GNU Stow, yq, YAML

---

### Task 1: Restructure config.yaml schema

**Files:**
- Modify: `config.yaml`

**Step 1: Rewrite config.yaml with new schema**

Convert the current `modules[].hosts[]` schema into separate `modules[]` and `machines[]` top-level keys. Module definitions go in `modules[]`, machine-to-module mappings go in `machines[]`.

```yaml
modules:
  - name: antigravity
    path: antigravity
  - name: bash
    path: bash
  - name: zsh
    path: zsh
  - name: fish
    path: fish
  - name: starship
    path: starship
  - name: shell-utils
    path: shell-utils
  - name: direnv
    path: direnv
  - name: git
    path: git
  - name: vim
    path: vim
  - name: nvim
    path: nvim
  - name: tmux
    path: tmux
  - name: ssh
    path: ssh
  - name: kitty
    path: kitty
  - name: rofi
    path: rofi
  - name: hyprland
    path: hyprland
  - name: waybar
    path: waybar
  - name: theme
    path: theme
  - name: sddm
    path: sddm
  - name: swaync
    path: swaync
  - name: wayvnc
    path: wayvnc
  - name: pip
    path: pip
  - name: uv
    path: uv
  - name: npm
    path: npm
  - name: podman
    path: podman
  - name: fonts
    path: fonts
  - name: yazi
    path: yazi

machines:
  - hostname: HOME-DESKTOP
    modules:
      - antigravity
      - bash
      - zsh
      - fish
      - starship
      - shell-utils
      - direnv
      - git
      - vim
      - nvim
      - tmux
      - ssh
      - kitty
      - rofi
      - hyprland
      - waybar
      - theme
      - sddm
      - swaync
      - wayvnc
      - pip
      - uv
      - npm
      - podman
      - fonts
      - yazi
  - hostname: ASUS-LAPTOP
    modules:
      - bash
      - zsh
      - fish
      - starship
      - shell-utils
      - direnv
      - git
      - vim
      - nvim
      - tmux
      - ssh
      - kitty
      - rofi
      - hyprland
      - waybar
      - theme
      - sddm
      - swaync
      - wayvnc
      - pip
      - uv
      - npm
      - podman
      - fonts
      - yazi
  - hostname: asus-vivobook
    modules:
      - bash
      - zsh
      - fish
      - starship
      - shell-utils
      - direnv
      - git
      - vim
      - nvim
      - tmux
      - ssh
      - pip
      - uv
      - npm
      - fonts
      - yazi
  - hostname: WORK-MACBOOK
    modules:
      - bash
      - zsh
      - starship
      - shell-utils
      - direnv
      - git
      - vim
      - nvim
      - tmux
      - ssh
      - pip
      - uv
      - npm
      - fonts
      - yazi
  - hostname: CODESPACES
    modules:
      - bash
      - zsh
      - starship
      - shell-utils
      - direnv
      - git
      - vim
      - nvim
      - tmux
      - ssh
      - pip
      - uv
      - npm
      - yazi
  - hostname: DESKTOP-OKTKL4S
    modules:
      - bash
      - zsh
      - fish
      - starship
      - shell-utils
      - direnv
      - git
      - vim
      - nvim
      - tmux
      - ssh
      - pip
      - uv
      - npm
      - fonts
      - yazi
```

Derive the machine → module mappings from the current `config.yaml` by reading which hosts each module currently lists.

**Step 2: Validate the conversion**

Run: `yq '.machines[] | .hostname' config.yaml`
Expected: Lists all 6 hostnames.

Run: `yq '.modules[] | .name' config.yaml`
Expected: Lists all 26 module names.

Cross-check: for each machine, count modules matches the current config. E.g., HOME-DESKTOP should have 26 modules, CODESPACES fewer (no kitty, rofi, hyprland, etc.).

**Step 3: Commit**

```bash
git add config.yaml
git commit -m "refactor: split config.yaml into modules[] + machines[] schema"
```

---

### Task 2: Add missing yazi/deps.yaml

**Files:**
- Create: `yazi/deps.yaml`

**Step 1: Create deps.yaml for yazi**

```yaml
# yazi module dependencies
packages:
  arch:
    - yazi
    - ffmpeg
    - p7zip
    - jq
    - poppler
    - fd
    - ripgrep
    - fzf
    - zoxide
    - imagemagick
  debian:
    - ffmpeg
    - p7zip-full
    - jq
    - poppler-utils
    - fd-find
    - ripgrep
    - fzf
    - imagemagick
  fedora:
    - ffmpeg
    - p7zip
    - jq
    - poppler-utils
    - fd-find
    - ripgrep
    - fzf
    - ImageMagick
  macos:
    - yazi
    - ffmpeg
    - p7zip
    - jq
    - poppler
    - fd
    - ripgrep
    - fzf
    - zoxide
    - imagemagick

cargo:
  - yazi-fm
  - yazi-cli
```

Note: On Arch, yazi is in the official repos. On Debian/Fedora, it needs cargo install. The `cargo` section handles the latter. The packages listed are yazi's optional dependencies for previews.

**Step 2: Commit**

```bash
git add yazi/deps.yaml
git commit -m "feat: add deps.yaml for yazi module"
```

---

### Task 3: Add shell guards to unguarded scripts

**Files:**
- Modify: `bash/.config/bash/80-yazi.bash`
- Modify: `zsh/.config/zsh/80-yazi.zsh`
- Modify: `fish/.config/fish/conf.d/80-yazi.fish`
- Modify: `bash/.config/bash/70-ssh-agent.bash`
- Modify: `zsh/.config/zsh/70-ssh-agent.zsh`
- Modify: `fish/.config/fish/conf.d/70-ssh-agent.fish`

**Step 1: Add yazi guard to all 3 shells**

For `bash/.config/bash/80-yazi.bash`, add after the comment header:
```bash
command -v yazi &>/dev/null || return 0
```

For `zsh/.config/zsh/80-yazi.zsh`, add after the comment header:
```bash
command -v yazi &>/dev/null || return 0
```

For `fish/.config/fish/conf.d/80-yazi.fish`, add after the comment header:
```fish
command -v yazi &>/dev/null; or return
```

**Step 2: Add ssh-agent guard to all 3 shells**

The ssh-agent scripts already have a `SSH_AUTH_SOCK` guard but don't check if `ssh-agent` binary exists. Add the binary check as the first guard, before the `SSH_AUTH_SOCK` check.

For `bash/.config/bash/70-ssh-agent.bash`, add at line 3 (before the SSH_AUTH_SOCK check):
```bash
command -v ssh-agent &>/dev/null || return 0
```

For `zsh/.config/zsh/70-ssh-agent.zsh`, add at line 3:
```bash
command -v ssh-agent &>/dev/null || return 0
```

For `fish/.config/fish/conf.d/70-ssh-agent.fish`, add at line 3:
```fish
command -v ssh-agent &>/dev/null; or return
```

**Step 3: Verify guards work**

Open a shell and confirm no errors on startup. The guards should be silent no-ops when tools are present.

**Step 4: Commit**

```bash
git add bash/.config/bash/80-yazi.bash zsh/.config/zsh/80-yazi.zsh fish/.config/fish/conf.d/80-yazi.fish
git add bash/.config/bash/70-ssh-agent.bash zsh/.config/zsh/70-ssh-agent.zsh fish/.config/fish/conf.d/70-ssh-agent.fish
git commit -m "fix: add command guards to yazi and ssh-agent shell scripts"
```

---

### Task 4: Split 40-plugins into per-tool files (bash)

**Files:**
- Delete: `bash/.config/bash/40-plugins.bash`
- Create: `bash/.config/bash/40-fzf.bash`
- Create: `bash/.config/bash/41-bash-completion.bash`
- Create: `bash/.config/bash/42-pkgfile.bash`

**Step 1: Create 40-fzf.bash**

```bash
# ~/.config/bash/40-fzf.bash
# FZF integration — keybindings and completion

command -v fzf &>/dev/null || return 0

# FZF provides native bash integration since v0.48+
if fzf --bash &>/dev/null; then
  eval "$(fzf --bash)"
elif [[ -f "/usr/share/fzf/key-bindings.bash" ]]; then
  source /usr/share/fzf/key-bindings.bash
  [[ -f "/usr/share/fzf/completion.bash" ]] && source /usr/share/fzf/completion.bash
elif [[ -f "$HOME/.fzf.bash" ]]; then
  source "$HOME/.fzf.bash"
fi
```

**Step 2: Create 41-bash-completion.bash**

```bash
# ~/.config/bash/41-bash-completion.bash
# Enable programmable completion

if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi
```

**Step 3: Create 42-pkgfile.bash**

```bash
# ~/.config/bash/42-pkgfile.bash
# pkgfile "command not found" handler (Arch-specific)

[[ -f "/usr/share/doc/pkgfile/command-not-found.bash" ]] && source /usr/share/doc/pkgfile/command-not-found.bash
```

**Step 4: Delete old 40-plugins.bash**

```bash
git rm bash/.config/bash/40-plugins.bash
```

**Step 5: Verify bash sources the new files**

Check that `.bashrc` or its loader sources `~/.config/bash/*.bash` via glob — if it does, the new files will be picked up automatically. Verify no errors on `bash --login`.

**Step 6: Commit**

```bash
git add bash/.config/bash/40-fzf.bash bash/.config/bash/41-bash-completion.bash bash/.config/bash/42-pkgfile.bash
git commit -m "refactor: split bash 40-plugins into per-tool files with guards"
```

---

### Task 5: Split 40-plugins into per-tool files (zsh)

**Files:**
- Delete: `zsh/.config/zsh/40-plugins.zsh`
- Create: `zsh/.config/zsh/40-fzf.zsh`
- Create: `zsh/.config/zsh/41-zsh-plugins.zsh`
- Create: `zsh/.config/zsh/42-completions.zsh`
- Create: `zsh/.config/zsh/43-pkgfile.zsh`

**Step 1: Create 40-fzf.zsh**

```zsh
# ~/.config/zsh/40-fzf.zsh
# FZF integration — keybindings and completion

command -v fzf &>/dev/null || return 0

# FZF provides native zsh integration since v0.48+
if fzf --zsh &>/dev/null; then
  eval "$(fzf --zsh)"
elif [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
  source /usr/share/fzf/key-bindings.zsh
  [[ -f "/usr/share/fzf/completion.zsh" ]] && source /usr/share/fzf/completion.zsh
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi
```

**Step 2: Create 41-zsh-plugins.zsh**

```zsh
# ~/.config/zsh/41-zsh-plugins.zsh
# Zsh plugins — loads from system packages if available

# Syntax highlighting
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# Autosuggestions
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done

# History substring search
for plugin_path in \
  "/usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "/usr/share/zsh-history-substring-search/zsh-history-substring-search.zsh" \
  "$HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh"; do
  if [[ -f "$plugin_path" ]]; then
    source "$plugin_path"
    break
  fi
done
```

**Step 3: Create 42-completions.zsh**

```zsh
# ~/.config/zsh/42-completions.zsh
# Zsh completion system initialization

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
```

**Step 4: Create 43-pkgfile.zsh**

```zsh
# ~/.config/zsh/43-pkgfile.zsh
# pkgfile "command not found" handler (Arch-specific)

[[ -f "/usr/share/doc/pkgfile/command-not-found.zsh" ]] && source /usr/share/doc/pkgfile/command-not-found.zsh
```

**Step 5: Delete old 40-plugins.zsh**

```bash
git rm zsh/.config/zsh/40-plugins.zsh
```

**Step 6: Verify zsh sources the new files**

Check that `.zshrc` sources `~/.config/zsh/*.zsh` via glob. Verify no errors on `zsh --login`.

**Step 7: Commit**

```bash
git add zsh/.config/zsh/40-fzf.zsh zsh/.config/zsh/41-zsh-plugins.zsh zsh/.config/zsh/42-completions.zsh zsh/.config/zsh/43-pkgfile.zsh
git commit -m "refactor: split zsh 40-plugins into per-tool files with guards"
```

---

### Task 6: Rewrite install.sh

**Files:**
- Modify: `install.sh`
- Delete: `bootstrap.sh`

This is the largest task. The new `install.sh` must:

1. Self-bootstrap (install stow + yq if missing)
2. Detect distro and package manager
3. Read the new config.yaml schema
4. For each module on this machine: install deps, backup conflicts, restow
5. Print summary

**Step 1: Write the new install.sh**

The script should reuse the proven helper functions from `bootstrap.sh` (distro detection, package manager mapping, deps.yaml OS key mapping, package installation). Strip out everything else from `bootstrap.sh` (font installation, shell plugin installation, shell changing, verification, post-install messages).

Key functions to port from `bootstrap.sh`:
- `detect_distro()` (lines 42-52)
- `get_package_manager()` (lines 54-86)
- `get_deps_os_key()` (lines 89-98)
- Package installation case statements

New functions to write:
- `self_bootstrap()` — install stow + yq if missing
- `install_deps_for_module()` — read a module's deps.yaml, install packages/cargo/pip/script
- `backup_conflicts()` — scan target dir for real files that would conflict with stow, move to backup dir
- `stow_module()` — run `stow --restow --no-folding` for a module
- `resolve_module_target()` — look up a module's target from config.yaml, with machine-level override support

The script structure:

```bash
#!/usr/bin/env bash
set -euo pipefail

# --- Logging ---
# Color-coded info/success/warn/error functions

# --- Detection ---
# detect_distro, get_package_manager, get_deps_os_key (from bootstrap.sh)

# --- Self-bootstrap ---
# Install stow + yq if not present

# --- Config parsing ---
# Read modules[] and machines[] from config.yaml
# Match hostname, get list of modules for this machine

# --- Per-module processing ---
# For each module:
#   1. Resolve path and target
#   2. Read deps.yaml → install packages, cargo, pip, script
#   3. Backup conflicting files in target
#   4. stow --restow --no-folding

# --- Summary ---
# Report: modules stowed, packages installed, files backed up, errors
```

**Step 2: Verify install.sh works on current machine**

Run: `./install.sh`
Expected: Detects hostname, processes modules for this machine, installs any missing deps, stows all modules.

Run: `./install.sh` a second time
Expected: Idempotent — no errors, no duplicate installs, summary shows everything already in place.

**Step 3: Delete bootstrap.sh**

```bash
git rm bootstrap.sh
```

**Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: rewrite install.sh as unified entrypoint with dep management and backup"
```

---

### Task 7: Audit and update deps.yaml files for multi-source deps

**Files:**
- Modify: `starship/deps.yaml` — add `script` section for Debian/Fedora where starship isn't in native repos
- Modify: `fonts/deps.yaml` — add `script` section for Nerd Font download on Debian/Fedora
- Audit all other deps.yaml files for missing `cargo`/`pip`/`script` entries

**Step 1: Update starship/deps.yaml**

```yaml
# starship module dependencies
packages:
  arch:
    - starship
  debian: []
  fedora: []
  macos:
    - starship

script:
  - url: https://starship.rs/install.sh
    args: ["--yes"]
    provides: starship
```

Add a `provides` field to script entries so install.sh can skip the script if the binary already exists.

**Step 2: Update fonts/deps.yaml**

```yaml
# fonts module dependencies
packages:
  arch:
    - fontconfig
    - ttf-jetbrains-mono-nerd
  debian:
    - fontconfig
  fedora:
    - fontconfig
  macos: []

script:
  - url: https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/install.sh
    args: ["JetBrainsMono"]
    provides: JetBrainsMonoNerdFont-Regular.ttf
```

**Step 3: Review each deps.yaml for completeness**

Walk through every module's deps.yaml comparing against what `bootstrap.sh` currently installs. Ensure nothing is lost in the migration. Key modules to check:
- `zsh/deps.yaml` — currently lists fzf and starship; these are soft deps from other modules, consider whether they should stay or be removed (since fzf and starship have their own modules)
- `bash/deps.yaml` — same situation with fzf and starship
- `fish/deps.yaml` — same

Decision: Shell modules should NOT list dependencies that belong to other modules (starship, fzf). Each module owns its own deps. Remove cross-module packages from shell deps.yaml files.

**Step 4: Commit**

```bash
git add */deps.yaml
git commit -m "feat: add multi-source deps (cargo/pip/script) and audit deps.yaml files"
```

---

### Task 8: Add shell completions to tool config fragments

**Files:**
- Modify: Various shell config fragments that activate tools with completion support

**Step 1: Identify tools with completion support**

Tools already in the shell configs that support completions:
- `kubectl` — `kubectl completion bash/zsh/fish`
- `docker`/`podman` — typically ship completions via package manager
- `terraform` — `terraform -install-autocomplete` (one-time) or completions via package
- `gh` — `gh completion -s bash/zsh/fish`
- `direnv` — completions bundled in `direnv hook`

**Step 2: Add completions where missing**

For each tool's config fragment, after the guard and activation, add completion setup if the tool supports it. Example for kubectl in `52-aliases-k8s.bash`:

```bash
# At end of file, after aliases:
# Completions
if command -v kubectl &>/dev/null; then
  eval "$(kubectl completion bash)"
fi
```

Similar for zsh and fish variants. Only add completions for tools that:
- Are already referenced in shell config fragments
- Have a dynamic completion generator command
- Don't already get completions from package manager install

**Step 3: Commit**

```bash
git add bash/.config/bash/ zsh/.config/zsh/ fish/.config/fish/
git commit -m "feat: add shell completions for kubectl, gh, and other tools"
```

---

### Task 9: Update CLAUDE.md and clean up

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Update CLAUDE.md**

Update the "Installation Process" section to reflect the new single `install.sh` entrypoint. Update the "Host Configuration" section to document the new `modules[]` + `machines[]` schema. Remove references to `bootstrap.sh`.

**Step 2: Final verification**

Run: `./install.sh`
Expected: Clean run on current machine, all modules stowed, no errors.

Verify: open each shell (bash, zsh, fish) and confirm no startup errors.

**Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for new install.sh and config schema"
```
