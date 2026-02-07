# Direnv Module

Automated direnv configuration for per-directory environment management.

## Overview

This module provides direnv integration for automatically loading and unloading environment variables based on the current directory. It includes custom layouts for common development scenarios and helper functions for enhanced functionality.

**Direnv** is a shell extension that loads and unloads environment variables depending on the current directory. It's perfect for:
- Project-specific environment variables
- Automatic virtual environment activation (Python, Node.js, etc.)
- Tool version management (via asdf, nvm, etc.)
- Loading secrets from `.env` files
- Per-project PATH modifications

## What's Included

### Configuration Files

- **`.config/direnv/direnvrc`** - Main entry point (modular library loader)
  - Loads standard direnv library (stdlib)
  - Sources modular layout libraries
  - Supports custom user extensions
  - Machine-specific overrides

- **`.config/direnv/lib/`** - Modular layout libraries:
  - `helpers.sh` - Reusable helper functions
  - `layout-python.sh` - Python layouts (venv, UV)
  - `layout-nodejs.sh` - Node.js layouts
  - `layout-golang.sh` - Go layouts
  - `layout-rust.sh` - Rust layouts
  - `layout-convenience.sh` - Convenience layouts (auto, env)
  - `layout-1password.sh` - 1Password secret management
  - `custom/` - User-defined custom layouts (optional)
  - `README.md` - Library documentation

- **`.config/direnv/direnv.toml`** - Global direnv configuration
  - Auto-approval whitelist for trusted directories
  - Directories listed here don't require `direnv allow` each time
  - Includes: `~/Projects`, `~/Documents`, `~/workspace`, `/tmp`
  - **Important**: .env files in auto-approved directories load automatically

### Utility Scripts

- **`.local/bin/direnv-status`** - Configuration status checker
  - Verifies direnv installation
  - Checks shell hook configuration
  - Lists allowed directories
  - Shows available custom layouts
  - Provides troubleshooting guidance

- **`.local/bin/direnv-init-python`** - Python project initializer
  - Detects Python projects automatically
  - Creates `.envrc` with UV layout
  - Runs `direnv allow` automatically
  - Interactive prompts for safety

- **`.local/bin/direnv-init-auto`** - Quick auto .env setup
  - Creates minimal `.envrc` with automatic .env loading
  - Perfect for simple projects that just need environment variables
  - Runs `direnv allow` automatically

- **`.local/bin/direnv-init-1password`** - 1Password integration setup
  - Creates `.envrc` with 1Password layout
  - Generates `.oprc` template with examples
  - Adds `.oprc` to `.gitignore`
  - Runs `direnv allow` automatically

- **`.local/bin/direnv-allow-common`** - Pre-allow common directories
  - Creates `.envrc` with auto .env loading in common directories
  - Allows directories automatically
  - Works with direnv.toml whitelist
  - Safe - checks for existing files

### Shell Hooks

Shell hooks are **not** included in this module. They are integrated into existing shell modules:
- Bash: `bash/.bashrc`
- Zsh: `zsh/.config/zsh/60-direnv.zsh`
- Fish: `fish/.config/fish/conf.d/60-direnv.fish`

All hooks use conditional loading, so shells work even if direnv is not installed.

## Installation

### Prerequisites

Direnv must be installed on your system:

```bash
# Debian/Ubuntu
sudo apt-get install direnv

# Arch Linux
sudo pacman -S direnv

# macOS (Homebrew)
brew install direnv

# From source
curl -sfL https://direnv.net/install.sh | bash
```

### Deployment

This module is deployed via the main `install.sh` script along with shell modules:

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

After deployment:
1. Start a new shell session (or source your shell config)
2. Run `direnv-status` to verify configuration
3. Navigate to a directory with `.envrc` and run `direnv allow`

## Auto-Approval and Automatic .env Loading

### Overview

This module provides automatic .env file loading for trusted directories. Once configured:
- **No manual `direnv allow`** needed in whitelisted directories
- **.env files load automatically** when you enter the directory
- **Secure** - only works in directories you explicitly trust

### Quick Setup

**Option 1: Use direnv-init-auto (simplest)**
```bash
cd /path/to/your/project
direnv-init-auto
echo 'export MY_VAR=value' > .env
cd .  # Environment loads automatically
```

**Option 2: Manual setup**
```bash
# Create .envrc
echo 'layout auto' > .envrc
direnv allow

# Create .env
echo 'export MY_VAR=value' > .env
```

### Auto-Approval Configuration

The `direnv.toml` file configures which directories are automatically approved:

**Default whitelisted directories**:
- `~/Projects/` - Your project directories
- `~/Documents/` - Document projects
- `~/workspace/` - Workspace directories
- `~/dev/` - Development directories
- `~/.local/share/dotfiles/` - This dotfiles repo
- `/workspaces/` - GitHub Codespaces workspace
- `/tmp/` - Temporary testing

**Location**: `~/.config/direnv/direnv.toml`

**How it works**:
1. Directories listed in `direnv.toml` are trusted
2. .envrc files in these directories don't require manual `direnv allow`
3. .env files are automatically loaded via `layout auto`

### Customizing Auto-Approved Directories

Edit `~/.config/direnv/direnv.toml`:

```toml
[whitelist]
prefix = [
    "/home/anirudh/Projects",
    "/home/anirudh/my-other-projects",
]
```

**Security Notes**:
- Only whitelist directories **you control**
- Never whitelist system directories or untrusted locations
- Review .envrc files before whitelisting their parent directory

### The layout auto Layout

The `layout auto` convenience layout automatically:
- Loads `.env` file if it exists
- Loads `.envrc.local` for machine-specific overrides
- Provides a minimal, clean environment setup

**Usage in .envrc**:
```bash
# Minimal setup - just load environment
layout auto

# Or combine with language layouts
layout uv        # Python with UV
layout auto      # Also load .env
```

### Setting Up Common Directories

Use `direnv-allow-common` to set up auto .env loading in all common directories:

```bash
direnv-allow-common
```

This creates `.envrc` files with `layout auto` in:
- ~/Documents
- ~/Projects
- ~/workspace
- /tmp

Now any .env file in these directories loads automatically!

### Example Workflow

```bash
# Set up a new project
mkdir ~/Projects/my-app
cd ~/Projects/my-app

# Initialize direnv with auto .env loading
direnv-init-auto

# Add environment variables
cat > .env << EOF
export DATABASE_URL="postgresql://localhost/mydb"
export API_KEY="secret-key-here"
export DEBUG=true
EOF

# Leave and re-enter directory - .env loads automatically
cd ..
cd my-app
# ✓ DATABASE_URL, API_KEY, DEBUG are now set!

# Check environment
echo $DATABASE_URL  # postgresql://localhost/mydb
```

## Custom Layouts

Custom layouts simplify common development environment setups. All layouts are organized in modular library files under `.config/direnv/lib/`.

### Python Virtual Environment (venv)

Creates and activates a Python virtual environment in `.venv/`:

```bash
# .envrc
layout python           # Uses python3 by default
layout python python3.11  # Use specific Python version
```

Features:
- Creates `.venv/` if it doesn't exist
- Activates virtual environment
- Adds `.venv/bin` to PATH
- Unsets PYTHONHOME to avoid conflicts
- Error messages with installation instructions

### Python with UV (Modern, Fast)

UV is a modern, fast Python package manager (Rust-based) that's significantly faster than pip and provides better dependency resolution:

```bash
# .envrc
layout uv              # Auto-detects Python version
layout uv 3.12         # Specific Python version
```

**Auto-detection features**:
- Reads `requires-python` from `pyproject.toml`
- Falls back to `.python-version` file
- Accepts manual version specification

**Benefits**:
- Significantly faster than pip/venv
- Built-in Python version management
- Better dependency resolution
- Modern best practices

**Requirements**:
- UV installed: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- Optional: `tomlq` for pyproject.toml parsing: `pip install yq`

**Example with auto-detection**:
```bash
# pyproject.toml
[project]
name = "my-project"
requires-python = ">=3.11"

# .envrc (automatically uses Python 3.11)
layout uv
```

### Node.js Project

Adds `node_modules/.bin` to PATH for local package binaries:

```bash
# .envrc
layout nodejs           # Uses current Node.js version
layout nodejs 18        # Use specific version via nvm (if available)
```

### Go Workspace

Sets up `GOPATH` in `.gopath/` directory:

```bash
# .envrc
layout golang
```

Creates directory structure:
- `.gopath/src/` - Source code
- `.gopath/pkg/` - Package objects
- `.gopath/bin/` - Compiled binaries (added to PATH)

### Rust Project

Adds local cargo bin to PATH:

```bash
# .envrc
layout rust
```

Respects `rust-toolchain` or `rust-toolchain.toml` files if present.

### 1Password Integration

Load secrets from 1Password automatically when entering a directory.

**Prerequisites**:
- 1Password CLI installed: `brew install --cask 1password-cli` or see [installation guide](https://developer.1password.com/docs/cli/get-started/)
- Authenticated: `eval $(op signin)`

**Basic usage**:
```bash
# .envrc
layout op           # Load secrets from .oprc or .env with op:// references
```

**Secret reference syntax**:
```bash
# .oprc or .env
DATABASE_URL=op://vault-name/item-name/password
API_KEY=op://production/api-keys/secret-key
SSH_KEY=op://development/ssh-key/private-key
```

**Dedicated secrets file** (`.oprc`):
```bash
# .oprc - 1Password secrets (add to .gitignore)
DATABASE_URL=op://production/database/url
STRIPE_SECRET_KEY=op://production/stripe/secret-key
JWT_SECRET=op://production/auth/jwt-secret

# .envrc
layout op
```

**Combined with regular environment variables**:
```bash
# .env - Regular environment variables
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# .oprc - 1Password secrets
DATABASE_PASSWORD=op://dev/postgres/password
API_KEY=op://dev/external-api/key

# .envrc
layout env_op      # Load .env first, then .oprc secrets
```

**With other layouts**:
```bash
# .envrc
layout python      # Set up Python virtual environment
layout op          # Load 1Password secrets

# Or for combined env + secrets
layout python
layout env_op
```

**Quick setup**:
```bash
cd /path/to/project
direnv-init-1password
# Edit .oprc and add your secret references
cd .  # Reload to load secrets
```

**Features**:
- Automatically resolves `op://` references to actual secret values
- Supports `.oprc` file for dedicated secrets management
- Falls back to `.env` if it contains `op://` references
- Error handling with helpful messages
- Works with direnv auto-approval for trusted directories

**Security notes**:
- Always add `.oprc` and `.env` to `.gitignore`
- Never commit files containing `op://` references
- Use `.envrc.local` for machine-specific non-secret overrides
- 1Password secrets are only available when authenticated

## Modular Library System

The direnv configuration uses a modular library system similar to the shell modules pattern.

### Structure

```
~/.config/direnv/
├── direnvrc                 # Main entry point (loads libraries)
└── lib/
    ├── helpers.sh           # Helper functions
    ├── layout-python.sh     # Python layouts
    ├── layout-nodejs.sh     # Node.js layouts
    ├── layout-golang.sh     # Go layouts
    ├── layout-rust.sh       # Rust layouts
    ├── custom/              # User-defined layouts (optional)
    └── README.md            # Library documentation
```

### Adding Custom Layouts

Create custom layouts without modifying core files:

```bash
# Create custom directory
mkdir -p ~/.config/direnv/lib/custom

# Add custom layout
cat > ~/.config/direnv/lib/custom/layout-docker.sh << 'EOF'
# layout-docker.sh - Docker development layouts

layout_docker() {
    export DOCKER_BUILDKIT=1
    export COMPOSE_DOCKER_CLI_BUILD=1

    if [[ -f docker-compose.yml ]]; then
        export COMPOSE_FILE=docker-compose.yml
        log_status "Docker Compose environment loaded"
    fi
}
EOF

# Use in .envrc
layout docker
```

Custom files are automatically loaded when direnv initializes.

### Overriding Layouts

To customize an existing layout:

1. Copy the layout to `custom/` directory
2. Modify as needed
3. Layouts in `custom/` are loaded last and override earlier definitions

## Helper Scripts

### direnv-init-auto

Quickly set up automatic .env loading in any directory:

```bash
cd /path/to/any/project
direnv-init-auto
```

**What it does**:
1. Creates minimal `.envrc` with `layout auto`
2. Runs `direnv allow` automatically
3. No language-specific setup - just environment variable loading

**Use cases**:
- Simple projects that only need environment variables
- Configuration directories
- Quick prototypes
- Non-programming projects (scripts, tools, etc.)

**Generated .envrc**:
```bash
# Automatically load .env files
layout auto
```

**Example workflow**:
```bash
mkdir ~/Projects/my-config
cd ~/Projects/my-config
direnv-init-auto
echo 'export API_URL=https://api.example.com' > .env
cd .  # Environment loads!
```

### direnv-init-python

Quickly initialize direnv for Python projects:

```bash
cd /path/to/python/project
direnv-init-python
```

**What it does**:
1. Detects if directory is a Python project (looks for pyproject.toml, setup.py, requirements.txt, etc.)
2. Creates `.envrc` with `layout uv`
3. Runs `direnv allow` automatically
4. Sets up environment loading with dotenv support

**Interactive prompts**:
- Asks before overwriting existing `.envrc`
- Confirms if directory doesn't look like a Python project

**Generated .envrc**:
```bash
# Automatically load Python environment with UV
layout uv

# Load .env file if it exists (for secrets)
dotenv_if_exists

# Machine-specific overrides
source_env_if_exists .envrc.local
```

### direnv-allow-common

Set up automatic .env loading in common project directories:

```bash
direnv-allow-common
```

**What it does**:
1. Creates `.envrc` files with `layout auto` in common directories:
   - `~/Documents`
   - `~/Projects`
   - `~/workspace`
   - `/tmp`
2. Runs `direnv allow` on each directory
3. Skips existing files and missing directories

**Generated .envrc**:
```bash
# Auto-load .env files in this directory and subdirectories
# This .envrc is for auto-approved directories in direnv.toml

# Automatically load .env if it exists
layout auto

# Uncomment if you need language-specific layouts:
# layout uv           # Python with UV
# layout python       # Python with venv
# layout nodejs       # Node.js project
# layout golang       # Go project
# layout rust         # Rust project
```

**Result**:
- Any .env file in these directories loads automatically
- Subdirectories inherit the behavior (unless they have their own .envrc)
- You can add language-specific layouts by uncommenting them

## Helper Functions

### Load .env Files

Safely load environment variables from `.env` files:

```bash
# .envrc
dotenv_if_exists        # Load .env if it exists
dotenv_if_exists .env.local  # Load custom env file
```

### Source Additional Files

Source other environment files:

```bash
# .envrc
source_env_if_exists .envrc.local  # Load local overrides
```

### Tool Version Management

Use asdf for version management:

```bash
# .envrc
use asdf nodejs         # Use Node.js version from .tool-versions
use asdf python 3.11.0  # Use specific version
```

Use Nix packages:

```bash
# .envrc
use_nix                 # Load environment from shell.nix
```

## Usage Examples

### Basic Environment Variables

```bash
# .envrc
export PROJECT_NAME="myproject"
export DEBUG=true
export API_URL="http://localhost:3000"
```

### Python Development (Traditional)

```bash
# .envrc
layout python python3.11
dotenv_if_exists
export PYTHONPATH="$PWD/src:$PYTHONPATH"
```

### Python Development (Modern with UV)

```bash
# .envrc
layout uv              # Auto-detects from pyproject.toml or .python-version
dotenv_if_exists
export PYTHONPATH="$PWD/src:$PYTHONPATH"
```

**Quick setup**:
```bash
# In your Python project
direnv-init-python
# Creates .envrc with UV layout and allows directory
```

### Node.js + TypeScript

```bash
# .envrc
layout nodejs 18
export NODE_ENV=development
PATH_add ./node_modules/.bin
```

### Multi-Language Project

```bash
# .envrc
# Python for backend
layout python

# Node.js for frontend
PATH_add frontend/node_modules/.bin

# Load environment variables
dotenv_if_exists

# Machine-specific overrides
source_env_if_exists .envrc.local
```

### Docker Development

```bash
# .envrc
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
export COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml
```

## Security

### Allowlist System

Direnv uses an allowlist to prevent malicious `.envrc` files from executing:

1. **Create `.envrc`** in your project directory
2. **Run `direnv allow`** to authorize the file
3. **Environment loads automatically** when you cd into the directory

The file hash is stored in `~/.config/direnv/allow/`. If the `.envrc` changes, you must run `direnv allow` again.

### Best Practices

- **Review `.envrc` files** before running `direnv allow`
- **Never commit secrets** to `.envrc` - use `.env` files instead
- **Add `.envrc` to `.gitignore`** for machine-specific configs
- **Use `.envrc.local`** for local overrides (also add to `.gitignore`)
- **Keep secrets in separate files** and load with `dotenv_if_exists`

### Example Setup

```bash
# Committed to git
.envrc                  # Project-wide environment
.env.example            # Template for required variables

# Local only (in .gitignore)
.envrc.local           # Machine-specific overrides
.env                   # Actual secrets and credentials
```

## Machine-Specific Overrides

### Per-Project Overrides

Create `.envrc.local` in your project:

```bash
# .envrc
layout python
source_env_if_exists .envrc.local  # Load local overrides
```

```bash
# .envrc.local (not committed)
export DATABASE_URL="postgresql://localhost/mydb_dev"
export AWS_PROFILE="personal"
```

### Global Overrides

Create `~/.config/direnv/direnvrc.local` for system-wide customizations:

```bash
# ~/.config/direnv/direnvrc.local
# Custom layout for your preferred stack
layout_mystack() {
    layout python
    layout nodejs
    export MY_CUSTOM_VAR="value"
}

# Override default Python version
layout_python() {
    local python=${1:-python3.11}
    # ... rest of layout
}
```

This file is automatically loaded by the main `direnvrc`.

## Troubleshooting

### Check Configuration Status

Run the diagnostic utility:

```bash
direnv-status
```

This shows:
- Direnv installation status
- Shell hook configuration
- Custom layouts available
- Allowed directories
- Quick start guide

### Common Issues

#### Environment Not Loading

```bash
# Check direnv status in directory
direnv status

# Allow the .envrc file
direnv allow

# Force reload
direnv reload
```

#### Shell Hook Not Working

Verify hook is loaded:

```bash
# Bash
grep "direnv hook" ~/.bashrc

# Zsh
grep "direnv hook" ~/.config/zsh/60-direnv.zsh

# Fish
grep "direnv hook" ~/.config/fish/conf.d/60-direnv.fish
```

Reload shell configuration:

```bash
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc

# Fish
source ~/.config/fish/config.fish
```

#### Layout Not Found

Check if custom layouts are loaded:

```bash
# In a directory with .envrc
direnv edit .
# Add: layout python
direnv allow
```

Verify direnvrc is in place:

```bash
ls -la ~/.config/direnv/direnvrc
```

#### Permission Denied

Ensure scripts are executable:

```bash
chmod +x ~/.local/bin/direnv-status
```

### Debug Mode

Enable debug output to see what direnv is doing:

```bash
export DIRENV_LOG_FORMAT="$(date '+%Y-%m-%d %H:%M:%S') %s"
direnv allow
cd .
```

## Integration with Other Tools

### asdf Version Manager

```bash
# .envrc
use asdf
```

Requires [direnv-asdf](https://github.com/asdf-community/asdf-direnv) plugin.

### Docker Compose

```bash
# .envrc
export COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml
export COMPOSE_PROJECT_NAME="${PWD##*/}"
dotenv_if_exists .env.docker
```

### Python Poetry

```bash
# .envrc
layout python python3.11
poetry env use python3.11
export VIRTUAL_ENV=$(poetry env info --path)
PATH_add "$VIRTUAL_ENV/bin"
```

### Git Hooks

Direnv works automatically with git hooks. The environment loads when you enter the repository.

## Resources

- **Official Documentation**: https://direnv.net/
- **Standard Library**: https://direnv.net/man/direnv-stdlib.1.html
- **GitHub**: https://github.com/direnv/direnv
- **Wiki**: https://github.com/direnv/direnv/wiki

## Module Configuration

Deployed to hosts: `HOME-DESKTOP`

Module structure:
```
direnv/
├── .config/direnv/
│   ├── direnvrc                      # Main entry point (library loader)
│   ├── direnv.toml                   # Auto-approval configuration
│   └── lib/
│       ├── helpers.sh                # Helper functions
│       ├── layout-python.sh          # Python layouts (venv, UV)
│       ├── layout-nodejs.sh          # Node.js layouts
│       ├── layout-golang.sh          # Go layouts
│       ├── layout-rust.sh            # Rust layouts
│       ├── layout-convenience.sh     # Convenience layouts (auto, env)
│       ├── layout-1password.sh       # 1Password secret management
│       └── README.md                 # Library documentation
├── .local/bin/
│   ├── direnv-status                 # Configuration checker
│   ├── direnv-init-python            # Python project initializer
│   ├── direnv-init-auto              # Auto .env loader setup
│   ├── direnv-init-1password         # 1Password integration setup
│   └── direnv-allow-common           # Common directories setup
└── README.md                         # This file
```

Shell hooks are managed in respective shell modules for separation of concerns.
