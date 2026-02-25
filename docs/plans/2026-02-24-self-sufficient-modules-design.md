# Self-Sufficient Modules Design

**Date:** 2026-02-24
**Status:** Approved
**Goal:** Simplify dotfiles architecture by making modules self-contained and removing redundant configuration

## Overview

The current dotfiles system has two sources of truth for module configuration: `config.yaml` defines modules with their paths and targets, while each module's `deps.yaml` defines dependencies. This creates maintenance overhead and risk of configuration drift.

This design eliminates the redundant `modules:[]` section from `config.yaml`, making each module self-sufficient through its `deps.yaml` file. Modules are auto-discovered from directories, dramatically simplifying the system.

## Design Principles

1. **Single Source of Truth:** Each module's `deps.yaml` is the complete definition
2. **Auto-Discovery:** No manual registration - any directory with `deps.yaml` is a valid module
3. **Explicit Prerequisites:** Cargo, pip, and paru must be available (auto-installed when possible)
4. **Backward Compatible Migration:** Changes to `deps.yaml` don't break old install.sh

## Module Structure & Discovery

### Module Discovery Mechanism

Every directory in the dotfiles root containing a `deps.yaml` file is automatically recognized as a module. The module name equals the directory name (e.g., `git/` becomes module "git").

### deps.yaml Format

Each module's `deps.yaml` becomes self-sufficient:

```yaml
# Optional: binaries/commands this module provides (for verification)
provides: [git]  # can be single string or list

# Dependencies - can be strings (packages) or objects (scripts)
packages:
  arch:
    - git                    # native package
    - aur:some-aur-package  # from AUR
    - cargo:ripgrep         # from cargo
  debian:
    - git
    - pip:some-package      # from pip
    - run: "curl https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship    # custom script for this platform
  fedora:
    - git
    - run: "curl https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  macos:
    - git
    - starship  # available in homebrew, no script needed
```

### Package Entry Types

Each entry in a platform's package list can be:

1. **String:** Package name with optional prefix
   - No prefix: native OS package (`git`, `neovim`)
   - `aur:`: Arch User Repository package (`aur:paru`)
   - `cargo:`: Rust crate (`cargo:ripgrep`)
   - `pip:`: Python package (`pip:pynvim`)

2. **Object:** Custom install script
   - `run`: Shell command to execute
   - `provides`: (optional) Binary name for verification

### System Prerequisites

The installer assumes these tools are available:
- **All systems:** Python 3 with pip, Rust with cargo
- **Arch systems only:** paru (AUR helper)

If prerequisites are missing:
- **Auto-install (no sudo):** cargo (via rustup), paru (via makepkg)
- **Fail-fast (requires sudo):** stow, yq, core utils

### Module Target Directory

By default, all modules are stowed to `$HOME`. Override per-module in machines section:

```yaml
machines:
  - hostname: "HOME-DESKTOP"
    modules:
      - "git"                    # uses default $HOME
      - name: "wayvnc"
        target: "$HOME/.config"  # override target
```

## Simplified config.yaml

The `modules:[]` section is removed entirely. Only `toolkits` and `machines` remain:

```yaml
# Toolkit definitions - group related modules
toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "zsh", "starship"]
  - name: "editors"
    modules: ["nvim"]
  - name: "dev-tools"
    modules: ["git", "tmux", "direnv"]
  - name: "wayland-desktop"
    modules: ["hyprland", "waybar", "swaync", "sddm", "rofi", "kitty", "theme", "fonts"]

# Machine profiles
machines:
  - hostname: "HOME-DESKTOP"
    modules:
      - "antigravity"
      - "wayland-desktop"      # toolkit reference
      - "python-dev"           # toolkit reference
      - name: "wayvnc"         # module with target override
        target: "$HOME/.config"

  - hostname: "codespaces-*"   # glob patterns supported
    modules:
      - "minimal-server"
      - "editors"
```

**Key Changes:**
1. No `modules:[]` section - modules are auto-discovered
2. Toolkits reference module names - validated at runtime
3. Machines reference toolkits or modules
4. Hostname patterns support globs

**Validation:**
When install.sh runs:
1. Scans directories for `deps.yaml` files
2. Expands toolkit references to module lists
3. Validates all referenced modules exist
4. Warns (but continues) if module not found

## install.sh Simplification

### Major Changes

**1. Bootstrap Phase:**
```bash
check_and_install_prerequisites() {
    # Check core utils (stow, yq, hostname) - fail-fast if missing
    # Auto-install cargo via rustup (non-interactive, no sudo)
    # Auto-install paru via makepkg on Arch (non-interactive, no sudo)
    # Verify python/pip available - fail-fast if missing
}
```

**2. Module Discovery:**
```bash
discover_modules() {
    # Scan $SCRIPT_DIR for directories containing deps.yaml
    # Return associative array: module_name -> directory_path
    # Module name = directory name (no override possible)
}
```

**3. Dependency Parsing (Simplified):**
```bash
parse_module_deps() {
    local module_name="$1"
    local deps_file="$module_path/deps.yaml"

    # For each platform entry (packages.arch, packages.debian, etc.)
    # Parse each item:
    #   - If string with "aur:" prefix -> add to aur_packages
    #   - If string with "cargo:" prefix -> add to cargo_packages
    #   - If string with "pip:" prefix -> add to pip_packages
    #   - If plain string -> add to native_packages
    #   - If object with "run" field -> add to install_scripts

    # Parse top-level "provides" field for verification
}
```

**4. Removed Functions:**
- `get_module_path()` - no longer needed (directory name = module name)
- `get_module_target()` - no longer needed (no module-level target in config)
- Separate top-level `aur:[]`, `cargo:[]`, `pip:[]` sections in deps.yaml

**5. Unified Installation Flow:**
```bash
install_all_dependencies() {
    # 1. Install all native packages (grouped by OS)
    # 2. Install all aur: packages (Arch only, using paru)
    # 3. Install all cargo: packages
    # 4. Install all pip: packages
    # 5. Run all platform-specific scripts
}
```

**6. Verification:**
```bash
verify_module() {
    local module_name="$1"
    # Read top-level "provides" field from deps.yaml
    # Check if each binary exists in $PATH
    # Warn if missing, but don't fail (non-blocking)
}
```

**Key Simplifications:**
- ~200 lines of module registry parsing removed
- No separate aur/cargo/pip top-level sections
- Single source of truth (deps.yaml per module)
- Clearer prerequisite checks upfront
- Auto-install prerequisites when possible (no sudo)

## Migration Path

### Step 1: Update deps.yaml Files

Add `provides` field and convert to prefix format:

**Before (starship/deps.yaml):**
```yaml
packages:
  arch: [starship]
  debian: []
  fedora: []
  macos: [starship]

script:
  - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
    provides: starship
```

**After (starship/deps.yaml):**
```yaml
provides: starship

packages:
  arch: [starship]
  debian:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  fedora:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  macos: [starship]
```

**Example with prefixes (yazi/deps.yaml):**
```yaml
provides: yazi

packages:
  arch: [yazi, ffmpeg, p7zip, ...]
  debian:
    - cargo:yazi-fm
    - cargo:yazi-cli
    - ffmpeg
    - p7zip-full
```

### Step 2: Simplify config.yaml
- Remove the entire `modules:[]` section (currently lines 3-59)
- Keep `toolkits:[]` and `machines:[]` as-is

### Step 3: Replace install.sh
- Backup old install.sh
- Deploy new simplified install.sh
- Test on each platform type (Arch, Debian, macOS)

### Rollback Plan
If issues arise, restore old `install.sh` and `config.yaml` from backup. The `deps.yaml` changes are backward-compatible (old install.sh ignores the `provides` field and prefix format).

## Edge Cases & Validation

### Edge Cases Handled

**1. Module Referenced but Missing:**
```bash
# Toolkit references "nvim" but nvim/ directory doesn't exist or has no deps.yaml
# Behavior: Warn and skip, continue with other modules
warn "Module 'nvim' referenced in toolkit 'editors' not found - skipping"
```

**2. Circular Toolkit References:**
```yaml
# Not supported - toolkits can only reference modules, not other toolkits
# Validation: Error if toolkit name appears in another toolkit's modules list
```

**3. Module Without provides Field:**
```yaml
# theme/deps.yaml has no "provides" field
# Behavior: Skip verification for this module, assume success after stow
```

**4. Duplicate Module References:**
```yaml
machines:
  - hostname: "HOME-DESKTOP"
    modules:
      - "terminal"    # includes "bash"
      - "bash"        # duplicate direct reference
# Behavior: Deduplicate, install only once, warn about duplication
```

**5. Platform-Specific Script Failures:**
```yaml
packages:
  debian:
    - run: "curl ... | sh"
      provides: tool
# If script fails but provides binary exists: Warn but continue
# If script fails and binary missing: Error and track in summary
```

**6. Missing Prerequisites (Auto-Install):**
```bash
check_and_install_prerequisites() {
    # Core tools (stow, yq) - fail-fast if missing, need sudo

    # Cargo/Rust - auto-install if missing
    if ! command -v cargo >/dev/null; then
        info "Installing Rust via rustup (non-interactive, no sudo)..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        source "$HOME/.cargo/env"
    fi

    # Python/pip - fail-fast if missing
    if ! command -v pip3 >/dev/null && ! command -v pip >/dev/null; then
        warn "pip not found - cannot auto-install without sudo"
        warn "Please install Python 3 with pip and re-run"
        exit 1
    fi

    # Paru (Arch only) - auto-install if missing
    if [[ "$PKG_MGR" == "pacman" ]] && ! command -v paru >/dev/null; then
        info "Installing paru from AUR (non-interactive, no sudo)..."
        temp_dir=$(mktemp -d)
        git clone https://aur.archlinux.org/paru.git "$temp_dir/paru"
        cd "$temp_dir/paru" && makepkg -si --noconfirm
        cd - && rm -rf "$temp_dir"
    fi
}
```

**Prerequisite Installation Rules:**
- **Can auto-install:** cargo (via rustup), paru (via makepkg on Arch)
- **Cannot auto-install:** stow, yq (need sudo) → fail fast with instructions
- **Usually present:** python/pip → fail fast with instructions if missing

### Validation Summary

- **Fail-fast:** Missing core tools that require sudo (stow, yq)
- **Auto-install:** cargo, paru (non-interactive, no sudo)
- **Warn and continue:** Missing module references, duplicate modules, script failures when binary exists
- **Track and report:** All warnings and errors in final summary

## Benefits

1. **Reduced Complexity:** ~200 lines removed from install.sh, entire modules[] section removed from config.yaml
2. **Single Source of Truth:** Module configuration lives entirely in its own directory
3. **Easier Maintenance:** Adding a module = create directory + deps.yaml (no config.yaml edit)
4. **No Configuration Drift:** Module name, path, and dependencies are co-located
5. **Better Error Messages:** Clearer prerequisite checks with auto-installation
6. **Backward Compatible Migration:** Changes don't break existing setup during transition

## Implementation Plan

See the implementation plan document for detailed step-by-step execution.
