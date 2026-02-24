# FZF Module Consolidation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete fzf module consolidation by removing obsolete script, adding Fish support, and applying Tokyo Night theme across all shells.

**Architecture:** Single self-contained integration file per shell (bash, zsh, fish) containing guard, availability check, Tokyo Night colors, and keybinding sourcing. Follows multi-module shell contributions pattern established in commit 37102fb.

**Tech Stack:** Bash, Zsh, Fish, fzf, GNU Stow

---

## Task 1: Remove Obsolete configure-fzf Script

**Files:**
- Delete: `zsh/.local/bin/configure-fzf`

**Rationale:** This script installs fzf from GitHub, but `fzf/deps.yaml` already handles installation via package manager. The script is obsolete and belongs to the old architecture where zsh module handled fzf setup.

**Step 1: Verify the script exists and is in zsh module**

```bash
ls -la zsh/.local/bin/configure-fzf
```

Expected: File exists at that path

**Step 2: Verify no other references to this script**

```bash
grep -r "configure-fzf" --exclude-dir=.git --exclude="*.md"
```

Expected: Only finds the script itself, no other code references

**Step 3: Delete the script**

```bash
git rm zsh/.local/bin/configure-fzf
```

**Step 4: Verify deletion**

```bash
ls -la zsh/.local/bin/
```

Expected: configure-fzf is gone, other configure-* scripts remain

**Step 5: Commit**

```bash
git commit -m "refactor(zsh): remove obsolete configure-fzf script

Script is obsolete - fzf/deps.yaml handles installation via package
manager. This completes fzf module consolidation.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Add Tokyo Night Theme to Bash Integration

**Files:**
- Modify: `fzf/.config/bash/40-fzf.bash`

**Step 1: Read current bash integration file**

```bash
cat fzf/.config/bash/40-fzf.bash
```

Expected: Simple file with guard, check, and keybinding sourcing

**Step 2: Update file with Tokyo Night colors**

Replace the entire file with:

```bash
# Guard against double-sourcing
[[ -n "${__BASH_FZF_LOADED+x}" ]] && return
__BASH_FZF_LOADED=1

# ~/.config/bash/40-fzf.bash
# FZF integration — keybindings, completion, and Tokyo Night theme

command -v fzf &>/dev/null || return 0

# Tokyo Night color scheme (matching starship theme)
export FZF_DEFAULT_OPTS="
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --border --height=40% --layout=reverse
  --preview-window=right:60%:wrap"

# Source from system/user files (works on all fzf versions)
if [[ -f "/usr/share/fzf/key-bindings.bash" ]]; then
  source /usr/share/fzf/key-bindings.bash
  [[ -f "/usr/share/fzf/completion.bash" ]] && source /usr/share/fzf/completion.bash
elif [[ -f "$HOME/.fzf.bash" ]]; then
  source "$HOME/.fzf.bash"
fi
```

**Step 3: Verify syntax**

```bash
bash -n fzf/.config/bash/40-fzf.bash
```

Expected: No output (clean syntax)

**Step 4: Stage the change**

```bash
git add fzf/.config/bash/40-fzf.bash
```

**Step 5: Verify diff**

```bash
git diff --cached fzf/.config/bash/40-fzf.bash
```

Expected: Shows addition of FZF_DEFAULT_OPTS with Tokyo Night colors

**Step 6: Commit**

```bash
git commit -m "feat(fzf): add Tokyo Night theme to Bash integration

Add cyberpunk-inspired Tokyo Night colors to match starship prompt:
- Dark background (#1a1b26)
- Cyan highlights (#7aa2f7, #7dcfff)
- Magenta accents (#bb9af7)
- Green markers (#9ece6a)

Also adds border, 40% height, reverse layout, and preview window.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Add Tokyo Night Theme to Zsh Integration

**Files:**
- Modify: `fzf/.config/zsh/40-fzf.zsh`

**Step 1: Read current zsh integration file**

```bash
cat fzf/.config/zsh/40-fzf.zsh
```

Expected: Simple file with guard, check, and keybinding sourcing

**Step 2: Update file with Tokyo Night colors**

Replace the entire file with:

```zsh
# Guard against double-sourcing
[[ -n "${__ZSH_FZF_LOADED+x}" ]] && return
__ZSH_FZF_LOADED=1

# ~/.config/zsh/40-fzf.zsh
# FZF integration — keybindings, completion, and Tokyo Night theme

command -v fzf &>/dev/null || return 0

# Tokyo Night color scheme (matching starship theme)
export FZF_DEFAULT_OPTS="
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --border --height=40% --layout=reverse
  --preview-window=right:60%:wrap"

# Source from system/user files (works on all fzf versions)
if [[ -f "/usr/share/fzf/key-bindings.zsh" ]]; then
  source /usr/share/fzf/key-bindings.zsh
  [[ -f "/usr/share/fzf/completion.zsh" ]] && source /usr/share/fzf/completion.zsh
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  source "$HOME/.fzf.zsh"
fi
```

**Step 3: Verify syntax**

```bash
zsh -n fzf/.config/zsh/40-fzf.zsh
```

Expected: No output (clean syntax)

**Step 4: Stage the change**

```bash
git add fzf/.config/zsh/40-fzf.zsh
```

**Step 5: Verify diff**

```bash
git diff --cached fzf/.config/zsh/40-fzf.zsh
```

Expected: Shows addition of FZF_DEFAULT_OPTS with Tokyo Night colors

**Step 6: Commit**

```bash
git commit -m "feat(fzf): add Tokyo Night theme to Zsh integration

Add cyberpunk-inspired Tokyo Night colors to match starship prompt:
- Dark background (#1a1b26)
- Cyan highlights (#7aa2f7, #7dcfff)
- Magenta accents (#bb9af7)
- Green markers (#9ece6a)

Also adds border, 40% height, reverse layout, and preview window.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Create Fish Integration with Tokyo Night Theme

**Files:**
- Create: `fzf/.config/fish/conf.d/40-fzf.fish`

**Step 1: Create fish directory if it doesn't exist**

```bash
mkdir -p fzf/.config/fish/conf.d
```

**Step 2: Create Fish integration file**

Create `fzf/.config/fish/conf.d/40-fzf.fish` with:

```fish
# Guard against double-sourcing
if set -q __FISH_FZF_LOADED
    exit 0
end
set -g __FISH_FZF_LOADED 1

# ~/.config/fish/conf.d/40-fzf.fish
# FZF integration — keybindings and Tokyo Night theme

# Check if fzf is available
if not type -q fzf
    exit 0
end

# Tokyo Night color scheme (matching starship theme)
set -gx FZF_DEFAULT_OPTS "
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --border --height=40% --layout=reverse
  --preview-window=right:60%:wrap"

# Configure fzf keybindings (Fish native)
if type -q fzf_configure_bindings
    # Use fzf.fish plugin if available
    fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs
else
    # Fallback: source system keybindings if available
    if test -f /usr/share/fish/vendor_functions.d/fzf_key_bindings.fish
        source /usr/share/fish/vendor_functions.d/fzf_key_bindings.fish
        fzf_key_bindings
    end
end
```

**Step 3: Verify syntax**

```bash
fish -n fzf/.config/fish/conf.d/40-fzf.fish
```

Expected: No output (clean syntax)

**Step 4: Stage the new file**

```bash
git add fzf/.config/fish/conf.d/40-fzf.fish
```

**Step 5: Verify file was staged**

```bash
git status fzf/.config/fish/conf.d/40-fzf.fish
```

Expected: Shows as "new file" staged for commit

**Step 6: Commit**

```bash
git commit -m "feat(fzf): add Fish shell integration with Tokyo Night theme

Add Fish shell support matching bash/zsh integration:
- Guard against double-sourcing
- Check fzf availability
- Tokyo Night colors matching starship prompt
- Keybinding configuration via fzf_configure_bindings
- Fallback to system keybindings if plugin unavailable

Completes multi-shell coverage for fzf module.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Verify All Integrations Work

**Files:**
- Test: `fzf/.config/bash/40-fzf.bash`
- Test: `fzf/.config/zsh/40-fzf.zsh`
- Test: `fzf/.config/fish/conf.d/40-fzf.fish`

**Step 1: Run install.sh to stow changes**

```bash
./install.sh
```

Expected: Successfully stows fzf module, no errors

**Step 2: Test Bash integration**

```bash
bash -l -c 'echo "FZF_DEFAULT_OPTS set: ${FZF_DEFAULT_OPTS:+yes}"'
```

Expected: Outputs "FZF_DEFAULT_OPTS set: yes"

**Step 3: Test Bash keybindings are defined**

```bash
bash -l -c 'type __fzf_history__ &>/dev/null && echo "✓ Bash fzf history function loaded" || echo "✗ Failed"'
```

Expected: Outputs "✓ Bash fzf history function loaded"

**Step 4: Test Zsh integration**

```bash
zsh -l -c 'echo "FZF_DEFAULT_OPTS set: ${FZF_DEFAULT_OPTS:+yes}"'
```

Expected: Outputs "FZF_DEFAULT_OPTS set: yes"

**Step 5: Test Zsh keybindings are defined**

```bash
zsh -l -c 'whence fzf-history-widget &>/dev/null && echo "✓ Zsh fzf history widget loaded" || echo "✗ Failed"'
```

Expected: Outputs "✓ Zsh fzf history widget loaded"

**Step 6: Test Fish integration**

```bash
fish -l -c 'echo "FZF_DEFAULT_OPTS set: "(set -q FZF_DEFAULT_OPTS && echo "yes" || echo "no")'
```

Expected: Outputs "FZF_DEFAULT_OPTS set: yes"

**Step 7: Visual test of Tokyo Night colors**

Open a new shell (any of bash/zsh/fish) and run:

```bash
fzf
```

Then type some text and verify:
- Background is dark Tokyo Night (#1a1b26)
- Highlights are cyan (#7aa2f7)
- Selected line has lighter background (#1f2335)
- Border is visible
- Press Ctrl+C to exit

Expected: Tokyo Night colors match starship prompt aesthetic

**Step 8: Test keybindings in interactive shell**

In a new shell session:
- Press `Ctrl+R` → should open fzf history search
- Press `Ctrl+T` → should open fzf file search (bash/zsh)
- Press `Alt+C` → should open fzf directory navigation (bash/zsh)

Expected: All keybindings work and display Tokyo Night colors

**Step 9: Document verification results**

Create a temporary verification log:

```bash
cat > /tmp/fzf-verification.txt << 'EOF'
# FZF Module Consolidation Verification

Date: $(date +%Y-%m-%d)

## Bash Integration
- [x] FZF_DEFAULT_OPTS exported
- [x] Keybindings loaded
- [x] Tokyo Night colors visible
- [x] Ctrl+R history search works

## Zsh Integration
- [x] FZF_DEFAULT_OPTS exported
- [x] Keybindings loaded
- [x] Tokyo Night colors visible
- [x] Ctrl+R history search works

## Fish Integration
- [x] FZF_DEFAULT_OPTS exported
- [x] Keybindings configured
- [x] Tokyo Night colors visible

## Module Consolidation
- [x] configure-fzf script removed from zsh
- [x] All fzf code in fzf module only
- [x] No fzf references in other modules

All tests passed ✓
EOF
cat /tmp/fzf-verification.txt
```

**Step 10: Clean up test log**

```bash
rm /tmp/fzf-verification.txt
```

---

## Task 6: Update Module Documentation

**Files:**
- Create: `docs/modules/fzf.md`

**Step 1: Create fzf module documentation**

Create `docs/modules/fzf.md` with:

```markdown
---
layout: default
title: "FZF Fuzzy Finder"
parent: Modules
---

# FZF Module

Command-line fuzzy finder with Tokyo Night theme and multi-shell integration.

## Features

- **Tokyo Night Theme** - cyberpunk colors matching starship prompt
- **Multi-Shell Support** - bash, zsh, and fish integration
- **System Keybindings** - Ctrl+R (history), Ctrl+T (files), Alt+C (directories)
- **Graceful Degradation** - works without errors if fzf not installed
- **Self-Contained** - all config in fzf module, no external dependencies

## Deployment

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

This deploys:
- `~/.config/bash/40-fzf.bash` - bash integration
- `~/.config/zsh/40-fzf.zsh` - zsh integration
- `~/.config/fish/conf.d/40-fzf.fish` - fish integration

## Color Scheme

Tokyo Night theme matching starship prompt:

| Element | Color | Hex |
|---------|-------|-----|
| Foreground | Light gray | #c0caf5 |
| Background | Dark Tokyo Night | #1a1b26 |
| Highlight | Magenta | #bb9af7 |
| Selection | Cyan | #7dcfff |
| Info | Blue | #7aa2f7 |
| Marker | Green | #9ece6a |

## Keybindings

### Bash & Zsh

- `Ctrl+R` - Search command history
- `Ctrl+T` - Search files in current directory
- `Alt+C` - Change directory via fuzzy search

### Fish

- `Ctrl+R` - Search command history
- `Ctrl+F` - Search directories (if fzf.fish installed)
- `Ctrl+G` - Search git log (if fzf.fish installed)
- `Ctrl+S` - Search git status (if fzf.fish installed)

## Customization

### Change Colors

Edit the `FZF_DEFAULT_OPTS` in:
- `fzf/.config/bash/40-fzf.bash`
- `fzf/.config/zsh/40-fzf.zsh`
- `fzf/.config/fish/conf.d/40-fzf.fish`

### Add Preview Commands

Add to `FZF_DEFAULT_OPTS`:

```bash
--preview 'bat --color=always --style=numbers --line-range=:500 {}'
```

### Change Default Command

Set in your shell config:

```bash
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
```

## Dependencies

Installed via `fzf/deps.yaml`:

```yaml
packages:
  arch:    [fzf]
  debian:  [fzf]
  fedora:  [fzf]
  macos:   [fzf]

requires:
  - fzf
```

The `requires` field ensures fzf binary is available before stowing config files.

## Troubleshooting

### Keybindings not working

Check if fzf keybindings sourced:

```bash
# Bash
type __fzf_history__

# Zsh
whence fzf-history-widget

# Fish
type fzf_key_bindings
```

### Colors not applied

Check FZF_DEFAULT_OPTS is set:

```bash
echo $FZF_DEFAULT_OPTS
```

Should show Tokyo Night color configuration.

### Fish integration not loading

Check if fzf is available and file is sourced:

```fish
type -q fzf && echo "fzf available" || echo "fzf not found"
set -q __FISH_FZF_LOADED && echo "fzf config loaded" || echo "not loaded"
```

## Integration with Other Tools

### Git Integration

fzf works with git commands:

```bash
git log --oneline | fzf --preview 'git show {1}'
git branch | fzf --preview 'git log --oneline {1}'
```

### Yazi File Manager

The yazi module includes fzf integration for fuzzy file finding within yazi.

### Vim/Neovim

fzf.vim plugin provides fuzzy file finding in vim/neovim (not included in this module).

## References

- [fzf GitHub](https://github.com/junegunn/fzf)
- [fzf.fish plugin](https://github.com/PatrickF1/fzf.fish)
- [Tokyo Night Theme](https://github.com/tokyo-night/tokyo-night-vscode-theme)
```

**Step 2: Stage the documentation**

```bash
git add docs/modules/fzf.md
```

**Step 3: Verify file staged**

```bash
git status docs/modules/fzf.md
```

Expected: Shows as "new file" staged for commit

**Step 4: Commit**

```bash
git commit -m "docs: add fzf module documentation

Document fzf module features, deployment, keybindings, and
customization. Includes Tokyo Night color reference and
troubleshooting guide.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Verify No fzf References in Other Modules

**Files:**
- Check: `zsh/`, `bash/`, `fish/` directories

**Step 1: Search for fzf in zsh module**

```bash
find zsh/ -type f -exec grep -l "fzf" {} \; 2>/dev/null
```

Expected: No results (all fzf code removed from zsh)

**Step 2: Search for fzf in bash module**

```bash
find bash/ -type f -exec grep -l "fzf" {} \; 2>/dev/null
```

Expected: No results (bash never had fzf code)

**Step 3: Search for fzf in fish module**

```bash
find fish/ -type f -exec grep -l "fzf" {} \; 2>/dev/null
```

Expected: No results (fish never had fzf code)

**Step 4: Search for configure-fzf references**

```bash
grep -r "configure-fzf" --exclude-dir=.git --exclude-dir=docs
```

Expected: No results (script deleted, docs can mention it)

**Step 5: Verify fzf module is complete**

```bash
ls -R fzf/
```

Expected output:
```
fzf/:
.config  .stow-local-ignore  deps.yaml

fzf/.config:
bash  fish  zsh

fzf/.config/bash:
40-fzf.bash

fzf/.config/fish:
conf.d

fzf/.config/fish/conf.d:
40-fzf.fish

fzf/.config/zsh:
40-fzf.zsh
```

**Step 6: Verify stow will work correctly**

```bash
stow --simulate --restow --no-folding --dir=. --target=$HOME fzf 2>&1 | grep -i conflict
```

Expected: No conflicts (empty output)

---

## Task 8: Final Integration Test

**Files:**
- Test: All modules

**Step 1: Create test script**

Create `/tmp/test-fzf-integration.sh`:

```bash
#!/usr/bin/env bash
set -e

echo "==================================="
echo "FZF Module Integration Test"
echo "==================================="
echo ""

# Test 1: Verify fzf binary
echo "Test 1: fzf binary available"
if command -v fzf &>/dev/null; then
    echo "✓ fzf version: $(fzf --version)"
else
    echo "✗ fzf not found"
    exit 1
fi
echo ""

# Test 2: Verify bash integration
echo "Test 2: Bash integration"
if bash -l -c '[[ -n "$FZF_DEFAULT_OPTS" ]]'; then
    echo "✓ Bash: FZF_DEFAULT_OPTS set"
else
    echo "✗ Bash: FZF_DEFAULT_OPTS not set"
    exit 1
fi
echo ""

# Test 3: Verify zsh integration
echo "Test 3: Zsh integration"
if zsh -l -c '[[ -n "$FZF_DEFAULT_OPTS" ]]'; then
    echo "✓ Zsh: FZF_DEFAULT_OPTS set"
else
    echo "✗ Zsh: FZF_DEFAULT_OPTS not set"
    exit 1
fi
echo ""

# Test 4: Verify fish integration
echo "Test 4: Fish integration"
if fish -l -c 'set -q FZF_DEFAULT_OPTS'; then
    echo "✓ Fish: FZF_DEFAULT_OPTS set"
else
    echo "✗ Fish: FZF_DEFAULT_OPTS not set"
    exit 1
fi
echo ""

# Test 5: Verify Tokyo Night colors in config
echo "Test 5: Tokyo Night colors configured"
if grep -q "#1a1b26" fzf/.config/bash/40-fzf.bash; then
    echo "✓ Tokyo Night colors in bash config"
else
    echo "✗ Tokyo Night colors missing in bash"
    exit 1
fi
echo ""

# Test 6: Verify no fzf in other modules
echo "Test 6: fzf code consolidated"
fzf_in_others=$(find zsh/ bash/ fish/ -type f -exec grep -l "fzf" {} \; 2>/dev/null | wc -l)
if [[ $fzf_in_others -eq 0 ]]; then
    echo "✓ No fzf references in other modules"
else
    echo "✗ Found fzf references in other modules"
    exit 1
fi
echo ""

echo "==================================="
echo "All tests passed! ✓"
echo "==================================="
```

**Step 2: Make test script executable**

```bash
chmod +x /tmp/test-fzf-integration.sh
```

**Step 3: Run integration test**

```bash
/tmp/test-fzf-integration.sh
```

Expected: All 6 tests pass with "All tests passed! ✓"

**Step 4: Clean up test script**

```bash
rm /tmp/test-fzf-integration.sh
```

**Step 5: Tag the completion**

```bash
git tag -a fzf-consolidation-v1.0 -m "FZF module consolidation complete

- Removed obsolete configure-fzf script from zsh
- Added Tokyo Night theme to bash/zsh integrations
- Created Fish integration with Tokyo Night theme
- All fzf code consolidated in fzf module
- Documentation added

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Step 6: View commit history**

```bash
git log --oneline --decorate --graph -n 8
```

Expected: Shows series of commits for fzf consolidation topped with tag

---

## Success Criteria

All criteria must be met:

- ✅ `zsh/.local/bin/configure-fzf` deleted
- ✅ Tokyo Night colors in `fzf/.config/bash/40-fzf.bash`
- ✅ Tokyo Night colors in `fzf/.config/zsh/40-fzf.zsh`
- ✅ New file `fzf/.config/fish/conf.d/40-fzf.fish` created
- ✅ All three shells export FZF_DEFAULT_OPTS
- ✅ Keybindings work in bash, zsh, fish
- ✅ No fzf references in zsh/bash/fish modules
- ✅ Documentation created at `docs/modules/fzf.md`
- ✅ Integration tests pass
- ✅ 5+ focused commits following conventional commits

## Testing Checklist

Manual verification in each shell:

**Bash:**
- [ ] Open bash session, verify Tokyo Night colors with `fzf`
- [ ] Test Ctrl+R (history search)
- [ ] Test Ctrl+T (file search)
- [ ] Test Alt+C (directory navigation)

**Zsh:**
- [ ] Open zsh session, verify Tokyo Night colors with `fzf`
- [ ] Test Ctrl+R (history search)
- [ ] Test Ctrl+T (file search)
- [ ] Test Alt+C (directory navigation)

**Fish:**
- [ ] Open fish session, verify Tokyo Night colors with `fzf`
- [ ] Test Ctrl+R (history search)
- [ ] Verify no errors on startup

**Module Isolation:**
- [ ] No fzf files in `zsh/`, `bash/`, `fish/` modules
- [ ] All fzf files in `fzf/` module only
- [ ] `stow --simulate` shows no conflicts

## Notes

- **Colors**: Tokyo Night palette matches starship prompt (#1a1b26 background)
- **Fish keybindings**: Uses fzf_configure_bindings if available, falls back to system bindings
- **Graceful degradation**: All integration files check for fzf binary before configuring
- **No breaking changes**: Existing bash/zsh configs enhanced, Fish config added
- **Idempotent**: Running install.sh multiple times is safe

## References

- Design Doc: `docs/plans/2026-02-24-fzf-module-design.md`
- Multi-module architecture: commit 37102fb
- Tokyo Night theme: https://github.com/tokyo-night/tokyo-night-vscode-theme
- fzf documentation: https://github.com/junegunn/fzf
