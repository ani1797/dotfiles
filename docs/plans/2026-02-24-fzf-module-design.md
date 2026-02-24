# FZF Module Consolidation Design

**Date:** 2026-02-24
**Status:** Approved
**Target:** Consolidate all fzf configuration into dedicated fzf module

## Overview

Consolidate all fzf (fuzzy finder) configuration into the existing fzf module following the multi-module shell contributions architecture. Currently, fzf integration files are correctly placed in the fzf module (created in commit 37102fb), but the configure-fzf installation script remains misplaced in the zsh module. This design completes the consolidation by removing the obsolete script, adding Fish shell support, and enhancing all shells with Tokyo Night theming to match the starship prompt.

## Requirements

1. **Complete Consolidation**: Remove all fzf-related code from other modules (specifically zsh)
2. **Fish Support**: Add Fish shell integration to match bash/zsh coverage
3. **Tokyo Night Theme**: Add cyberpunk-inspired colors matching the starship prompt theme
4. **Self-Contained**: Module includes all dependencies, configs, and integration files
5. **Graceful Degradation**: Work without errors if fzf is not installed

## Architecture

### Approach: Single File Per Shell (Approach 1)

Each shell gets one self-contained integration file that includes:
1. Double-source guard
2. fzf availability check
3. Tokyo Night color theme (FZF_DEFAULT_OPTS)
4. System keybindings and completion sourcing

**Why this approach:**
- Matches existing multi-module architecture pattern
- Self-contained files are simple to maintain
- Color duplication is minimal (~10 lines across 3 shells)
- No environment.d pattern exists in repo (would be over-engineering)

**Rejected alternatives:**
- Separate theme files: Adds complexity (6 files instead of 3)
- Shared environment.d: Requires new infrastructure for minimal benefit

## File Structure

```
fzf/
├── .config/
│   ├── bash/40-fzf.bash       # Bash: theme + keybindings
│   ├── zsh/40-fzf.zsh          # Zsh: theme + keybindings
│   └── fish/
│       └── conf.d/40-fzf.fish  # Fish: theme + keybindings (NEW)
├── .stow-local-ignore          # Exclude deps.yaml from stowing
└── deps.yaml                   # Package manager installation
```

### Integration File Structure

Each shell file follows this pattern:

```bash
# 1. Double-source guard
[[ -n "${__<SHELL>_FZF_LOADED+x}" ]] && return
__<SHELL>_FZF_LOADED=1

# 2. Check if fzf is available
command -v fzf &>/dev/null || return 0

# 3. Tokyo Night theme colors
export FZF_DEFAULT_OPTS="--color=<tokyo-night-colors>"

# 4. Source system keybindings
if [[ -f "/usr/share/fzf/key-bindings.<shell>" ]]; then
  source /usr/share/fzf/key-bindings.<shell>
  source /usr/share/fzf/completion.<shell>
elif [[ -f "$HOME/.fzf.<shell>" ]]; then
  source "$HOME/.fzf.<shell>"
fi
```

## Integration Points

### Shell Loading

- **Bash**: `.bashrc` sources `~/.config/bash/*.bash` in numeric order
- **Zsh**: `.zshrc` sources `~/.config/zsh/*.zsh` in numeric order
- **Fish**: Auto-sources `~/.config/fish/conf.d/*.fish` on startup

The `40-` prefix ensures fzf loads after utilities (20-) but before aliases (50-).

### System Keybindings Locations

- **Package manager installs**: `/usr/share/fzf/{key-bindings,completion}.{bash,zsh}`
  - Arch: `pacman -S fzf`
  - Debian/Ubuntu: `apt install fzf`
  - Fedora: `dnf install fzf`
  - macOS: `brew install fzf`
- **Manual installs**: `~/.fzf.{bash,zsh}` (fallback)
- **Fish**: Uses fzf's built-in `fzf_configure_bindings` function

### Tokyo Night Theme

FZF_DEFAULT_OPTS environment variable with ANSI color codes matching starship:
- Background: `#1a1b26` (dark Tokyo Night)
- Highlights: `#7aa2f7` (cyan)
- Accents: `#bb9af7` (magenta)
- Matched text: `#9ece6a` (green)

### Toolkit Membership

The fzf module is already in the `shell-utils` toolkit alongside yazi:

```yaml
toolkits:
  - name: shell-utils
    modules:
      - yazi
      - fzf
```

All machines already include fzf in their module lists.

## Migration Strategy

### Changes Required

1. **Delete**: `zsh/.local/bin/configure-fzf`
   - Obsolete: deps.yaml handles package manager installation
   - Script installs from GitHub, but package managers are preferred

2. **Update**: `fzf/.config/bash/40-fzf.bash`
   - Add Tokyo Night colors via FZF_DEFAULT_OPTS

3. **Update**: `fzf/.config/zsh/40-fzf.zsh`
   - Add Tokyo Night colors via FZF_DEFAULT_OPTS

4. **Create**: `fzf/.config/fish/conf.d/40-fzf.fish`
   - New Fish integration with colors and keybindings

### Safety

- No changes to `config.yaml` (fzf already configured)
- No changes to `deps.yaml` (already correct)
- Bash/zsh files already exist and work, just adding colors
- Changes are purely additive or cleanup

### Deployment

Users run `./install.sh` which:
1. Verifies fzf binary on $PATH (via `requires: [fzf]` in deps.yaml)
2. Stows enhanced/new files to `~/.config/{bash,zsh,fish}/`
3. Next shell session automatically picks up Tokyo Night theme

### Rollback

If colors aren't desired, remove the FZF_DEFAULT_OPTS lines - keybindings continue working with default colors.

## Error Handling

### Graceful Degradation

- Each shell file checks `command -v fzf` and exits silently if missing
- Double-source guards prevent conflicts if files are sourced multiple times
- Keybinding sources use conditional checks - if system files don't exist, keybindings simply don't load (no errors)

### Installation Failures

- If fzf binary is missing after deps.yaml installation, `install.sh` aborts before stowing
- The `requires: [fzf]` field in deps.yaml triggers this safety check
- Prevents broken symlinks to integration files when fzf isn't installed

### Fish-Specific Handling

Fish integration uses Fish-native patterns:
- `type -q fzf` instead of `command -v fzf` (Fish's command check)
- Uses `fzf_configure_bindings` function if available
- Falls back to manual keybinding setup if function doesn't exist

## Testing

### Manual Testing

After deployment, verify in each shell:

```bash
# Test fzf is available
fzf --version

# Test keybindings work
Ctrl+R    # History search
Ctrl+T    # File search
Alt+C     # Directory navigation

# Test colors applied
fzf      # Run and verify Tokyo Night colors
```

### Automated Checks

```bash
# Verify files stowed correctly
ls -l ~/.config/bash/40-fzf.bash
ls -l ~/.config/zsh/40-fzf.zsh
ls -l ~/.config/fish/conf.d/40-fzf.fish

# Verify no orphaned fzf files in other modules
find zsh/ -name "*fzf*"  # Should find nothing
find bash/ -name "*fzf*" # Should find nothing
find fish/ -name "*fzf*" # Should find nothing
```

## Success Criteria

1. ✅ All fzf code lives in fzf module only
2. ✅ configure-fzf script removed from zsh module
3. ✅ Fish integration added
4. ✅ Tokyo Night colors applied in all shells
5. ✅ Keybindings work in bash, zsh, and fish
6. ✅ Module works standalone (no dependencies on other modules)

## Future Enhancements

Potential additions (not in scope for this design):

- FZF_DEFAULT_COMMAND configuration (e.g., use fd instead of find)
- Custom preview commands for file/directory selection
- Additional color schemes beyond Tokyo Night
- Integration with git (fzf-based branch/commit selection)
