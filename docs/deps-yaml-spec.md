# deps.yaml Specification

Complete reference for the `deps.yaml` module dependency format.

## Overview

Every module must have a `deps.yaml` file in its root directory. This file defines:
- What the module provides (for verification)
- Dependencies per platform (packages, scripts)
- Installation methods (native packages, AUR, cargo, pip, custom scripts)

## File Structure

```yaml
# Optional: What binaries/commands this module provides
provides: <string | string[]>

# Required: Platform-specific dependencies
packages:
  arch: <package-entry[]>
  debian: <package-entry[]>
  fedora: <package-entry[]>
  macos: <package-entry[]>
```

## Field Reference

### `provides` (Optional)

**Type:** `string` or `string[]`

**Description:** Binary names or commands that this module installs, used for verification after installation.

**Examples:**

```yaml
# Single binary
provides: git

# Multiple binaries
provides: [yazi, ya]

# Binary with different name than package
provides: nvim  # package is 'neovim', binary is 'nvim'
```

**Behavior:**
- After module installation, installer checks if these binaries exist in `$PATH`
- Warns if missing but doesn't fail (non-blocking)
- If omitted, no verification is performed

**Best Practice:** Always include `provides` for modules that install executables.

---

### `packages` (Required)

**Type:** Object mapping platform keys to package entry arrays

**Description:** Platform-specific dependency lists. Each platform can have different package names or installation methods.

**Platform Keys:**
- `arch` - Arch Linux, Manjaro, EndeavourOS, CachyOS
- `debian` - Debian, Ubuntu, Pop!_OS, Linux Mint
- `fedora` - Fedora, RHEL, CentOS, Rocky, AlmaLinux
- `macos` - macOS with Homebrew

**Examples:**

```yaml
packages:
  arch: [git, ripgrep, fd]
  debian: [git, ripgrep, fd-find]  # Different package name
  fedora: [git, ripgrep, fd-find]
  macos: [git, ripgrep, fd]
```

---

### Package Entry Types

Each entry in a platform's package list can be:

#### 1. Plain String (Native Package)

**Format:** `package-name`

**Description:** Package from the OS's native package manager.

**Examples:**

```yaml
packages:
  arch: [git, neovim, tmux]
  debian: [git, neovim, tmux]
```

**Behavior:**
- Installed via `pacman`, `apt`, `dnf`, or `brew` depending on platform
- Skipped if already installed
- Fails if package not found in repos

---

#### 2. AUR Package (Arch Only)

**Format:** `aur:package-name`

**Description:** Package from the Arch User Repository.

**Examples:**

```yaml
packages:
  arch:
    - git                 # Official repo
    - aur:paru            # AUR package
    - aur:visual-studio-code-bin
```

**Prerequisites:**
- Only works on Arch Linux
- Requires `paru` (auto-installed if missing)

**Behavior:**
- Installed via `paru -S package-name`
- Skipped if already installed
- Fails if paru not available or package not found in AUR

**Best Practice:** Provide alternatives for other platforms:

```yaml
packages:
  arch:
    - aur:visual-studio-code-bin
  debian:
    - run: "curl https://packages.microsoft.com/... | sh"
      provides: code
  macos:
    - visual-studio-code
```

---

#### 3. Cargo Package (Rust)

**Format:** `cargo:crate-name`

**Description:** Package from crates.io (Rust package registry).

**Examples:**

```yaml
packages:
  arch:
    - cargo:ripgrep       # Install via cargo instead of pacman
    - cargo:bat
    - cargo:eza
  debian:
    - cargo:ripgrep       # Not in Debian repos, use cargo
    - cargo:bat
```

**Prerequisites:**
- Requires Rust and cargo (auto-installed if missing via rustup)

**Behavior:**
- Installed via `cargo install crate-name`
- Skipped if already installed (`cargo install --list` check)
- Compilation happens locally (can be slow)

**Version Pinning:**

```yaml
packages:
  arch:
    - cargo:ripgrep@13.0.0  # Specific version
```

**Best Practice:** Use native packages when available (faster), cargo as fallback.

---

#### 4. Pip Package (Python)

**Format:** `pip:package-name`

**Description:** Package from PyPI (Python Package Index).

**Examples:**

```yaml
packages:
  arch:
    - neovim
    - pip:pynvim          # Python client for Neovim
  debian:
    - neovim
    - pip:pynvim
    - pip:black           # Python formatter
```

**Prerequisites:**
- Requires Python 3 with pip

**Behavior:**
- Installed via `pip install --user package-name`
- Installed to user directory (no sudo)
- Skipped if already installed

**Version Pinning:**

```yaml
packages:
  debian:
    - pip:pynvim==0.4.3   # Specific version
    - pip:black>=22.0.0   # Minimum version
```

**Best Practice:** Use `--user` install (handled automatically by installer).

---

#### 5. Custom Script

**Format:** Object with `run` and optional `provides`

**Description:** Custom installation command when packages aren't available.

**Fields:**
- `run` (required): Shell command to execute
- `provides` (optional): Binary name to check for verification

**Examples:**

```yaml
packages:
  debian:
    - git
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
```

**Multiple scripts:**

```yaml
packages:
  debian:
    - run: |
        curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
        apt-get install -y nodejs
      provides: node
    - run: "npm install -g typescript"
      provides: tsc
```

**Behavior:**
- Executes shell command directly
- If `provides` is set and binary exists, skips execution
- Captures output and errors
- Non-zero exit code tracked as warning

**Best Practice:**
- Always include `provides` for idempotency
- Use `--yes` or `-y` flags for non-interactive installs
- Quote multiline scripts with `|` or `>`

---

## Complete Examples

### Simple Module (Single Package)

```yaml
# git/deps.yaml
provides: git

packages:
  arch: [git]
  debian: [git]
  fedora: [git]
  macos: [git]
```

---

### Mixed Sources

```yaml
# nvim/deps.yaml
provides: nvim

packages:
  arch:
    - neovim              # Native
    - ripgrep             # Native
    - cargo:tree-sitter-cli  # Cargo
  debian:
    - neovim
    - ripgrep
    - pip:pynvim          # Pip
    - cargo:tree-sitter-cli
  macos:
    - neovim
    - ripgrep
```

---

### Platform-Specific Scripts

```yaml
# starship/deps.yaml
provides: starship

packages:
  arch:
    - starship  # In official repos
  debian:
    # Not in repos, use install script
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  fedora:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  macos:
    - starship  # In homebrew
```

---

### Complex Application

```yaml
# yazi/deps.yaml
provides: [yazi, ya]

packages:
  arch:
    - yazi             # Main package
    - ffmpeg           # Video preview
    - p7zip            # Archive support
    - jq               # JSON processing
    - poppler          # PDF preview
    - fd               # File search
    - ripgrep          # Content search
    - fzf              # Fuzzy finder
    - zoxide           # Smart cd
    - imagemagick      # Image processing
  debian:
    - cargo:yazi-fm    # Not in Debian repos
    - cargo:yazi-cli
    - ffmpeg
    - p7zip-full
    - jq
    - poppler-utils
    - fd-find
    - ripgrep
    - fzf
    - zoxide
    - imagemagick
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
```

---

### No Dependencies (Config Only)

```yaml
# theme/deps.yaml
# No provides field - just configuration files
# No dependencies - assuming theme programs already installed

packages:
  arch: []
  debian: []
  fedora: []
  macos: []
```

Or simply omit platforms with no dependencies:

```yaml
# theme/deps.yaml
packages: {}
```

---

## Validation Rules

### Required Fields
- ✅ `packages` object must exist (can be empty)

### Optional Fields
- ✅ `provides` can be omitted if no verification needed

### Platform Keys
- ✅ Platforms in `packages` can be omitted if not supported
- ✅ Valid platforms: `arch`, `debian`, `fedora`, `macos`
- ⚠️ Unknown platform keys are ignored

### Package Entry Validation
- ✅ Plain strings are native packages
- ✅ `aur:`, `cargo:`, `pip:` prefixes must have package name after colon
- ✅ Script objects must have `run` field
- ⚠️ Script objects with missing `provides` skip verification
- ❌ Invalid prefix (e.g., `npm:`) causes warning and skip

### Common Mistakes

**Missing colon in prefix:**
```yaml
# ❌ Wrong
packages:
  arch: [aurparu]  # Treated as native package "aurparu"

# ✅ Correct
packages:
  arch: [aur:paru]
```

**Using script without platform nesting:**
```yaml
# ❌ Wrong (script at top level)
script:
  - run: "curl ... | sh"

# ✅ Correct (script in platform array)
packages:
  debian:
    - run: "curl ... | sh"
      provides: tool
```

**Providing empty arrays unnecessarily:**
```yaml
# ⚠️ Verbose
packages:
  arch: [git]
  debian: [git]
  fedora: []    # Not needed
  macos: []     # Not needed

# ✅ Cleaner
packages:
  arch: [git]
  debian: [git]
```

---

## Migration from Old Format

If your `deps.yaml` has separate top-level `aur`, `cargo`, `pip`, or `script` sections, migrate to the new prefix format:

**Old Format:**
```yaml
provides: starship

packages:
  arch: [starship]
  debian: []

script:
  - run: "curl ... | sh"
    provides: starship
```

**New Format:**
```yaml
provides: starship

packages:
  arch: [starship]
  debian:
    - run: "curl ... | sh"
      provides: starship
```

**Old Format (Multiple Sources):**
```yaml
packages:
  arch: [neovim, ripgrep]

cargo:
  - tree-sitter-cli

pip:
  - pynvim
```

**New Format:**
```yaml
provides: nvim

packages:
  arch:
    - neovim
    - ripgrep
    - cargo:tree-sitter-cli
    - pip:pynvim
```

---

## Best Practices

1. **Always include `provides`** for modules that install executables
2. **Use native packages when available** - faster and more reliable than cargo/pip
3. **Provide alternatives for all platforms** - or document why platform isn't supported
4. **Include `provides` in scripts** - enables idempotency checks
5. **Quote multiline scripts** - use `|` for literal newlines
6. **Test on all platforms** - package names differ between distros
7. **Document unusual choices** - use YAML comments for complex installations

---

## Related Documentation

- [Module Creation Guide](module-creation.md) - How to create modules
- [config.yaml Specification](config-yaml-spec.md) - Machine and toolkit configuration
- [Installation Guide](installation.md) - Installing dotfiles on a new system
