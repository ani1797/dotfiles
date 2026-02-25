# Module Creation Guide

This guide covers creating new modules for the dotfiles system.

## What is a Module?

A **module** is a self-contained unit of configuration that:
- Lives in its own directory under the dotfiles root
- Contains configuration files to be symlinked to your home directory
- Defines its dependencies in a `deps.yaml` file
- Declares what binaries/tools it provides (for verification)

Module name always equals directory name (no override possible).

## Module Structure

### Basic Structure

```
my-module/
├── deps.yaml                    # Required: Dependencies and metadata
├── .stow-local-ignore          # Optional: Files to exclude from stowing
├── .config/                    # Configuration files
│   └── myapp/
│       └── config.yaml
├── .local/                     # Local user files
│   └── share/
│       └── myapp/
└── .myapprc                    # Dotfiles in home directory
```

### Directory Layout for Stow

GNU Stow creates symlinks by mirroring your module's directory structure. Files in the module root map to your home directory:

```
Module file:              Symlinked to:
my-module/.bashrc      -> $HOME/.bashrc
my-module/.config/app/ -> $HOME/.config/app/
my-module/.local/bin/  -> $HOME/.local/bin/
```

## Creating a New Module

### Step 1: Create Directory

```bash
cd ~/.local/share/dotfiles
mkdir my-module
cd my-module
```

### Step 2: Add Configuration Files

Organize files as they should appear in your home directory:

```bash
# Dotfile in home directory
echo "alias ll='ls -la'" > .bashrc

# Config file in ~/.config/
mkdir -p .config/myapp
echo "setting: value" > .config/myapp/config.yaml

# Executable in ~/.local/bin/
mkdir -p .local/bin
cat > .local/bin/mytool << 'EOF'
#!/bin/bash
echo "Hello from mytool"
EOF
chmod +x .local/bin/mytool
```

### Step 3: Create deps.yaml

Create a `deps.yaml` file defining the module's dependencies:

```yaml
# What binary/command this module provides (for verification)
provides: myapp  # or [myapp, mytool] for multiple

# Dependencies per platform
packages:
  arch:
    - myapp              # Native package
    - aur:myapp-plugin   # AUR package (Arch only)
  debian:
    - myapp
    - pip:myapp-cli      # Python package via pip
  fedora:
    - myapp
  macos:
    - myapp
```

See [deps.yaml Specification](deps-yaml-spec.md) for complete format reference.

### Step 4: Test Locally

Test the module without affecting your system:

```bash
# Stow to a test directory
mkdir -p /tmp/test-home
stow --dir=.. --target=/tmp/test-home my-module

# Verify symlinks
ls -la /tmp/test-home

# Clean up test
stow --dir=.. --target=/tmp/test-home -D my-module
rmdir /tmp/test-home
```

### Step 5: Add to Machine Profile

Edit `config.yaml` and add your module:

```yaml
machines:
  - hostname: "your-hostname"
    modules:
      - "my-module"  # Direct module reference
      # or add to a toolkit first
```

### Step 6: Run Installer

```bash
cd ~/.local/share/dotfiles
./install.sh
```

The installer will:
1. Discover your new module (finds `deps.yaml`)
2. Install dependencies
3. Verify installation (checks for `provides` binaries)
4. Stow configuration files

## Common Patterns

### Simple Configuration Module (No Dependencies)

For modules that only provide configuration files with no external dependencies:

```yaml
# git/deps.yaml
provides: git  # Assumes git is already installed

packages:
  arch: [git]
  debian: [git]
  fedora: [git]
  macos: [git]
```

### Multi-Platform Script Installation

For tools not available in all package managers:

```yaml
# starship/deps.yaml
provides: starship

packages:
  arch: [starship]  # In official repos
  debian:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  fedora:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  macos: [starship]  # In homebrew
```

### Module with Multiple Dependencies

For complex applications with many dependencies:

```yaml
# nvim/deps.yaml
provides: nvim

packages:
  arch:
    - neovim
    - ripgrep
    - fd
    - lua-language-server
    - pyright
    - cargo:tree-sitter-cli  # Rust package
  debian:
    - neovim
    - ripgrep
    - fd-find
    - pip:pynvim             # Python package
    - cargo:tree-sitter-cli
  macos:
    - neovim
    - ripgrep
    - fd
    - lua-language-server
```

### Language Runtime Module

For language runtimes that need post-install configuration:

```yaml
# python/deps.yaml
provides: [python3, pip3]

packages:
  arch:
    - python
    - python-pip
    - python-virtualenv
  debian:
    - python3
    - python3-pip
    - python3-venv
  macos:
    - python3
```

### Desktop Application Module

For GUI applications with themes/fonts:

```yaml
# kitty/deps.yaml
provides: kitty

packages:
  arch:
    - kitty
    - kitty-terminfo
  debian:
    - kitty
  macos:
    - kitty
```

## Advanced Topics

### Excluding Files from Stow

Create a `.stow-local-ignore` file to exclude files/directories:

```bash
# my-module/.stow-local-ignore
\.git
\.gitignore
^/README.*
^/LICENSE.*
deps\.yaml
```

Common patterns:
- `\.git` - Exclude .git directory
- `^/README.*` - Exclude README files at module root
- `deps\.yaml` - Exclude deps.yaml itself
- `.*\.swp` - Exclude vim swap files

### Custom Target Directories

Most modules stow to `$HOME`, but you can override per-module:

```yaml
# config.yaml
machines:
  - hostname: "your-hostname"
    modules:
      - name: "sddm"
        target: "/etc/sddm"  # System-level config
```

Note: Stowing to system directories requires sudo:
```bash
sudo stow --dir=/path/to/dotfiles --target=/etc sddm
```

### Conditional Dependencies

For dependencies that should only install on specific machines:

**Option 1: Create separate modules**
```
nvim-minimal/     # Basic nvim + essential LSPs
nvim-full/        # All LSPs and tools
```

**Option 2: Use machine-specific toolkits**
```yaml
# config.yaml
toolkits:
  - name: "dev-minimal"
    modules: ["nvim-minimal"]
  - name: "dev-full"
    modules: ["nvim-full"]

machines:
  - hostname: "laptop"
    modules: ["dev-minimal"]
  - hostname: "workstation"
    modules: ["dev-full"]
```

### Module Dependencies

If one module requires another, document it but don't enforce:

```yaml
# zsh/deps.yaml
provides: zsh

# Note: Recommends starship module for prompt
packages:
  arch: [zsh]
  debian: [zsh]
```

Users should add both to their machine profile:
```yaml
modules:
  - "zsh"
  - "starship"  # Optional but recommended
```

### Version Pinning

For cargo/pip packages that need specific versions:

```yaml
packages:
  arch:
    - cargo:ripgrep@13.0.0  # Pin to specific version
  debian:
    - pip:pynvim==0.4.3     # Python pinning syntax
```

Note: Native packages don't support pinning (uses latest from repos).

### AUR Packages

AUR packages are only available on Arch Linux and require paru:

```yaml
packages:
  arch:
    - aur:paru               # AUR helper itself
    - aur:some-aur-package   # Package from AUR
  debian:
    # Provide alternative or skip
    - run: "curl ... | sh"
      provides: some-package
```

The installer auto-installs paru if missing on Arch systems.

## Testing Modules

### Test Dependency Installation

Test only dependency installation (don't stow):

```bash
# Extract and manually run install commands
yq -r '.packages.arch[]' my-module/deps.yaml

# For arch packages
sudo pacman -S <package>

# For aur packages
paru -S <package>

# For cargo packages
cargo install <package>

# For pip packages
pip install --user <package>
```

### Test Stowing

Stow to a temporary directory to verify structure:

```bash
mkdir -p /tmp/stow-test
stow --dir=~/.local/share/dotfiles --target=/tmp/stow-test --verbose my-module
tree /tmp/stow-test
```

### Test on Virtual Machine

For major changes, test on a clean VM:

1. Spin up VM with target OS (Arch/Debian/etc.)
2. Clone dotfiles repository
3. Add test machine profile to `config.yaml`
4. Run `./install.sh`
5. Verify configuration works

## Module Checklist

When creating a new module, ensure:

- [ ] Directory name matches desired module name
- [ ] `deps.yaml` exists and is valid YAML
- [ ] `provides` field lists verifiable binaries
- [ ] Dependencies are specified for all supported platforms
- [ ] Platform-specific prefixes used correctly (aur:, cargo:, pip:)
- [ ] Scripts include `provides` field
- [ ] Configuration files follow target directory structure
- [ ] `.stow-local-ignore` excludes metadata files
- [ ] Module added to `config.yaml` (toolkit or machine)
- [ ] Tested with `./install.sh` on target platform
- [ ] Binary verification passes (command exists after install)

## Examples

### Minimal Example (Git)

```
git/
├── deps.yaml
└── .gitconfig
```

```yaml
# git/deps.yaml
provides: git

packages:
  arch: [git]
  debian: [git]
  fedora: [git]
  macos: [git]
```

### Complex Example (Neovim)

```
nvim/
├── deps.yaml
├── .stow-local-ignore
└── .config/
    └── nvim/
        ├── init.lua
        ├── lua/
        │   ├── core/
        │   ├── plugins/
        │   └── lsp/
        └── after/
            └── ftplugin/
```

```yaml
# nvim/deps.yaml
provides: nvim

packages:
  arch:
    - neovim
    - ripgrep
    - fd
    - lua-language-server
    - pyright
    - typescript-language-server
    - rust-analyzer
    - gopls
    - bash-language-server
  debian:
    - neovim
    - ripgrep
    - fd-find
    - pip:pynvim
    - cargo:tree-sitter-cli
  macos:
    - neovim
    - ripgrep
    - fd
    - lua-language-server
```

## Next Steps

- Review [deps.yaml Specification](deps-yaml-spec.md) for complete format details
- See [config.yaml Specification](config-yaml-spec.md) for toolkit/machine configuration
- Check [Troubleshooting](troubleshooting.md) for common module issues
