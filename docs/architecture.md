# Architecture Overview

This document explains how the dotfiles management system works internally.

## Table of Contents

- [System Overview](#system-overview)
- [Core Concepts](#core-concepts)
- [Installation Flow](#installation-flow)
- [Module Discovery](#module-discovery)
- [Dependency Resolution](#dependency-resolution)
- [Stowing Process](#stowing-process)
- [File Organization](#file-organization)

---

## System Overview

The dotfiles system manages configuration files across multiple machines using:

- **GNU Stow** - Creates symlinks from module directories to target directories
- **YAML Configuration** - Machine profiles and module dependencies
- **Auto-Discovery** - Modules are found automatically from directory structure
- **Multi-Platform** - Supports Arch, Debian, Fedora, macOS with appropriate package managers

### Design Principles

1. **Self-Sufficient Modules** - Each module contains all its metadata and dependencies
2. **Auto-Discovery** - No central registry, modules found by scanning directories
3. **Idempotent** - Safe to run repeatedly, skips already-installed items
4. **Non-Destructive** - Backs up conflicting files before overwriting
5. **Platform-Agnostic** - Same configuration adapts to different OSes

---

## Core Concepts

### Module

A **module** is a self-contained unit of configuration:
- Directory containing configuration files
- `deps.yaml` defining dependencies
- Module name equals directory name
- Stowed to target directory (default: `$HOME`)

```
git/
├── deps.yaml        # Dependencies and metadata
├── .gitconfig       # Will be stowed to ~/.gitconfig
└── .config/         # Will be stowed to ~/.config/
    └── git/
        └── ignore
```

### Toolkit

A **toolkit** is a named group of modules defined in `config.yaml`:

```yaml
toolkits:
  - name: "python-dev"
    modules: ["pip", "uv"]
```

Purpose:
- Reduce repetition in machine profiles
- Provide semantic grouping
- Make configurations more maintainable

### Machine Profile

A **machine profile** maps hostnames to module lists:

```yaml
machines:
  - hostname: "laptop"
    modules: ["python-dev", "git", "nvim"]
```

Supports:
- Exact hostname matching
- Glob patterns (`codespaces-*`)
- Case-insensitive matching
- Per-module target overrides

### Stow Target

The **stow target** is the directory where module files are symlinked:
- Default: `$HOME`
- Override: Per-module in machine profile
- Supports environment variables (`$HOME`, `$XDG_CONFIG_HOME`)

---

## Installation Flow

The installer (`install.sh`) follows this workflow:

### Phase 1: Environment Detection

```bash
1. Detect OS/distro (Arch, Debian, Fedora, macOS)
2. Detect package manager (pacman, apt, dnf, brew)
3. Get current hostname
4. Determine OS key for deps.yaml (arch, debian, fedora, macos)
```

### Phase 2: Prerequisites Check

```bash
1. Check core utilities (stow, yq, hostname, find, grep, etc.)
2. Auto-install prerequisites if possible:
   - cargo (via rustup, no sudo)
   - paru (via makepkg, Arch only, no sudo)
3. Fail-fast for tools requiring sudo (stow, yq)
4. Fail-fast for missing Python/pip
```

### Phase 3: Module Discovery

```bash
1. Scan dotfiles directory for subdirectories
2. Check each subdirectory for deps.yaml
3. Create map: module_name -> directory_path
4. Module name = directory name (no override)
```

### Phase 4: Configuration Parsing

```bash
1. Load config.yaml
2. Find machine profile matching current hostname
3. Expand toolkit references to module lists
4. Deduplicate module references
5. Validate all modules exist (warn if missing)
6. Collect target overrides from machine profile
```

### Phase 5: Dependency Collection

```bash
For each selected module:
  1. Read deps.yaml
  2. Extract platform-specific packages
  3. Parse package entries:
     - Plain strings -> native packages
     - "aur:" prefix -> AUR packages
     - "cargo:" prefix -> cargo packages
     - "pip:" prefix -> pip packages
     - Objects with "run" -> install scripts
  4. Collect all into platform-specific lists
  5. Deduplicate across all modules
```

### Phase 6: Dependency Installation

```bash
1. Install native packages (bulk, via package manager)
2. Install AUR packages (Arch only, via paru)
3. Install cargo packages (one at a time)
4. Install pip packages (bulk, user install)
5. Run install scripts (check "provides" first)
```

### Phase 7: Verification

```bash
For each module with "provides" field:
  1. Check if binary exists in $PATH
  2. Warn if missing (non-blocking)
```

### Phase 8: Stowing

```bash
For each module:
  1. Determine target directory
  2. Scan module for conflicts (existing non-symlink files)
  3. Backup conflicting files to ~/.dotfiles-backup/TIMESTAMP/
  4. Remove conflicting files
  5. Run stow --restow --no-folding --verbose
  6. Track success/failure
```

### Phase 9: Summary

```bash
Print summary:
  - Modules stowed (count and list)
  - Packages installed (by type)
  - Scripts executed
  - Files backed up (with location)
  - Errors encountered
```

---

## Module Discovery

### Discovery Algorithm

```bash
discover_modules() {
    for dir in "$DOTFILES_ROOT"/*/; do
        if [[ -f "$dir/deps.yaml" ]]; then
            module_name=$(basename "$dir")
            modules["$module_name"]="$dir"
        fi
    done
}
```

### Module Name Resolution

Module name is always the directory name:
```
dotfiles/git/        -> module "git"
dotfiles/nvim/       -> module "nvim"
dotfiles/my-module/  -> module "my-module"
```

No override possible. To rename module, rename directory.

### Validation

Modules referenced in `config.yaml` are validated at runtime:
1. Toolkit expands to module list
2. Each module name checked against discovered modules
3. Warnings generated for missing modules
4. Installation continues with available modules

---

## Dependency Resolution

### Parsing deps.yaml

For each module:

```bash
parse_deps() {
    local module="$1"
    local os_key="$2"  # arch, debian, fedora, macos

    # Extract provides field (optional)
    provides=$(yq -r '.provides // empty' "$module/deps.yaml")

    # Extract package list for this OS
    packages=$(yq -r ".packages.$os_key[]? // empty" "$module/deps.yaml")

    for pkg in $packages; do
        case "$pkg" in
            aur:*)
                # Extract "aur:package-name" -> "package-name"
                aur_packages+=("${pkg#aur:}")
                ;;
            cargo:*)
                # Extract "cargo:crate-name" -> "crate-name"
                cargo_packages+=("${pkg#cargo:}")
                ;;
            pip:*)
                # Extract "pip:package-name" -> "package-name"
                pip_packages+=("${pkg#pip:}")
                ;;
            *)
                # Check if it's a script object
                if is_object "$pkg"; then
                    run_cmd=$(yq -r '.run' <<< "$pkg")
                    provides=$(yq -r '.provides // empty' <<< "$pkg")
                    scripts+=("$run_cmd|$provides")
                else
                    # Plain package name
                    native_packages+=("$pkg")
                fi
                ;;
        esac
    done
}
```

### Dependency Deduplication

After collecting from all modules:

```bash
# Remove duplicates, preserve order
native_packages=($(printf '%s\n' "${native_packages[@]}" | sort -u))
aur_packages=($(printf '%s\n' "${aur_packages[@]}" | sort -u))
cargo_packages=($(printf '%s\n' "${cargo_packages[@]}" | sort -u))
pip_packages=($(printf '%s\n' "${pip_packages[@]}" | sort -u))
```

### Installation Order

Dependencies installed in this order:

1. **Native packages** - Fastest, from OS repos
2. **AUR packages** - Arch only, builds from source
3. **Cargo packages** - Cross-platform, compiles locally
4. **Pip packages** - Python packages, pre-built wheels
5. **Scripts** - Custom installs, platform-specific

This order ensures:
- Fast installs first (native packages)
- Build tools available before compiling (cargo)
- Scripts run after all packages available

---

## Stowing Process

### Stow Fundamentals

GNU Stow creates symlinks by mirroring directory structure:

```
Module:                  Target:
git/.gitconfig        -> $HOME/.gitconfig
git/.config/git/      -> $HOME/.config/git/
```

### Conflict Detection

Before stowing, installer scans for conflicts:

```bash
detect_conflicts() {
    local module_dir="$1"
    local target_dir="$2"

    find "$module_dir" -type f | while read src_file; do
        # Calculate target path
        rel_path="${src_file#$module_dir/}"
        target_file="$target_dir/$rel_path"

        # Check if file exists and is NOT a symlink
        if [[ -f "$target_file" && ! -L "$target_file" ]]; then
            conflicts+=("$target_file")
        fi
    done
}
```

### Backup Strategy

Conflicting files are backed up before stowing:

```bash
backup_conflicts() {
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_dir="$HOME/.dotfiles-backup/$timestamp"

    for file in "${conflicts[@]}"; do
        # Preserve directory structure
        rel_path="${file#$HOME/}"
        backup_path="$backup_dir/$rel_path"

        mkdir -p "$(dirname "$backup_path")"
        cp "$file" "$backup_path"
        rm "$file"
    done
}
```

Backup locations:
- `~/.dotfiles-backup/YYYYMMDD-HHMMSS/`
- Preserves relative paths
- Only real files backed up (not symlinks)
- Backups are never deleted automatically

### Stow Execution

```bash
stow_module() {
    local module_name="$1"
    local target_dir="$2"

    stow \
        --restow \           # Re-stow (update existing)
        --no-folding \       # Don't fold directories
        --verbose \          # Show actions
        --dir="$DOTFILES_ROOT" \
        --target="$target_dir" \
        "$module_name"
}
```

Flags explained:
- `--restow`: Updates existing symlinks, removes stale ones
- `--no-folding`: Creates symlinks for each file, not whole directories
- `--verbose`: Shows what's being linked
- `--dir`: Source directory containing modules
- `--target`: Destination directory for symlinks

### Stow Ignore Files

Each module can have `.stow-local-ignore`:

```
\.git
^/README.*
^/LICENSE.*
deps\.yaml
```

Patterns:
- `\.git` - Exclude .git directory
- `^/` - Exclude from module root only
- `.*\.swp` - Exclude all matching pattern

These files are never stowed.

---

## File Organization

### Repository Structure

```
dotfiles/
├── install.sh              # Main installer
├── config.yaml             # Machine and toolkit config
├── docs/                   # Documentation
│   ├── README.md
│   ├── installation.md
│   ├── module-creation.md
│   ├── deps-yaml-spec.md
│   ├── config-yaml-spec.md
│   ├── troubleshooting.md
│   ├── architecture.md
│   └── plans/
│       └── YYYY-MM-DD-*.md
├── bash/                   # Module: bash
│   ├── deps.yaml
│   ├── .bashrc
│   └── .config/...
├── nvim/                   # Module: nvim
│   ├── deps.yaml
│   └── .config/nvim/...
└── ... (other modules)
```

### Module Internal Structure

Modules mirror target directory structure:

```
nvim/
├── deps.yaml               # Not stowed (ignored)
├── .stow-local-ignore      # Not stowed (stow metadata)
└── .config/                # Stowed to ~/.config/
    └── nvim/
        ├── init.lua        -> ~/.config/nvim/init.lua
        ├── lua/
        │   ├── core/
        │   └── plugins/
        └── after/
```

### Target Directory Layout

After stowing, home directory contains symlinks:

```
$HOME/
├── .bashrc          -> ../.local/share/dotfiles/bash/.bashrc
├── .gitconfig       -> ../.local/share/dotfiles/git/.gitconfig
└── .config/
    ├── nvim/        -> ../../.local/share/dotfiles/nvim/.config/nvim/
    └── starship.toml -> ../../.local/share/dotfiles/starship/.config/starship.toml
```

Symlinks are relative (portable across systems).

---

## Data Flow Diagram

```
┌─────────────────┐
│   config.yaml   │
└────────┬────────┘
         │
         ├─► Machines: hostname → modules
         └─► Toolkits: name → modules
                       │
                       ▼
         ┌─────────────────────────┐
         │  Module Auto-Discovery  │
         │  (scan for deps.yaml)   │
         └──────────┬──────────────┘
                    │
         ┌──────────▼───────────┐
         │  Module Resolution   │
         │  (expand toolkits,   │
         │   deduplicate)       │
         └──────────┬───────────┘
                    │
         ┌──────────▼────────────┐
         │  Dependency Collection│
         │  (parse deps.yaml     │
         │   from each module)   │
         └──────────┬────────────┘
                    │
         ┌──────────▼────────────┐
         │  Install Dependencies │
         │  (packages, cargo,    │
         │   pip, scripts)       │
         └──────────┬────────────┘
                    │
         ┌──────────▼────────────┐
         │    Verification       │
         │    (check provides)   │
         └──────────┬────────────┘
                    │
         ┌──────────▼────────────┐
         │  Conflict Detection   │
         │  (find existing files)│
         └──────────┬────────────┘
                    │
         ┌──────────▼────────────┐
         │    Backup Files       │
         │    (if conflicts)     │
         └──────────┬────────────┘
                    │
         ┌──────────▼────────────┐
         │    Stow Modules       │
         │    (create symlinks)  │
         └──────────┬────────────┘
                    │
                    ▼
            ┌───────────────┐
            │    Summary    │
            └───────────────┘
```

---

## Key Design Decisions

### Why Auto-Discovery?

**Problem:** Maintaining both `config.yaml` modules list and actual module directories creates sync issues.

**Solution:** Scan directories for `deps.yaml`, making modules self-sufficient.

**Benefits:**
- Single source of truth (deps.yaml per module)
- Adding module = create directory + deps.yaml (no config.yaml edit)
- No risk of config.yaml getting out of sync
- Simpler system with less configuration

### Why Prefix-Based Package Sources?

**Problem:** Separate top-level `aur:[]`, `cargo:[]`, `pip:[]` sections in deps.yaml required parsing multiple sections.

**Solution:** Use prefixes (`aur:`, `cargo:`, `pip:`) within platform package lists.

**Benefits:**
- Single package list per platform
- Clear source for each package
- Platform-specific alternatives easy (Debian uses cargo:, Arch uses native)
- Simpler parsing logic

### Why Non-Blocking Verification?

**Problem:** Verification failures (binary not found) could halt installation.

**Solution:** Verification warns but doesn't fail.

**Rationale:**
- Binary might be in non-standard PATH
- Binary might have different name than package
- Some modules don't install binaries
- User can see warnings and fix if needed
- Installation completes for other modules

### Why Backup Before Stow?

**Problem:** Stow fails if files already exist, losing user's existing config.

**Solution:** Automatically backup conflicting files before stowing.

**Benefits:**
- Non-destructive (existing config saved)
- Timestamped backups (multiple runs don't overwrite)
- User can review and merge old config
- Installation proceeds even with conflicts

---

## Extension Points

The system can be extended in several ways:

### Custom Package Sources

Add new prefix types by extending the parsing logic:

```bash
case "$pkg" in
    # Existing prefixes
    aur:*) ... ;;
    cargo:*) ... ;;
    pip:*) ... ;;

    # New prefix
    npm:*)
        npm_packages+=("${pkg#npm:}")
        ;;
esac
```

### Post-Install Hooks

Add module-specific post-install scripts:

```yaml
# deps.yaml
packages:
  arch: [nvim]

post_install:
  - run: "nvim --headless +PlugInstall +qall"
```

### Platform-Specific Targets

Override targets per-platform in modules:

```yaml
# deps.yaml
target:
  linux: "$HOME/.config"
  macos: "$HOME/Library/Application Support"
```

### Dependency Ordering

Add `requires` field for module dependencies:

```yaml
# deps.yaml
requires: [fonts, theme]  # Install these first
```

---

## Related Documentation

- [Installation Guide](installation.md) - How to install the system
- [Module Creation Guide](module-creation.md) - How to create modules
- [deps.yaml Specification](deps-yaml-spec.md) - Module dependency format
- [config.yaml Specification](config-yaml-spec.md) - System configuration format
- [Troubleshooting](troubleshooting.md) - Common issues and solutions
