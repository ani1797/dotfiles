---
layout: default
title: "Git Configuration"
parent: Modules
---

# Git Module

Modern git configuration with best practices, useful aliases, and 1Password integration.

## Overview

This module provides a comprehensive git configuration including:
- User identity and signing configuration
- Global gitignore patterns
- Commit message template
- Useful aliases for common operations
- Better diff and merge settings
- Helper scripts for verification and setup

## What's Included

### Configuration Files

- **`.gitconfig`** - Main git configuration
  - User identity (name, email, signing key)
  - SSH-based commit signing (1Password)
  - Default branch (main)
  - Pull/push/fetch defaults
  - Better diff and merge algorithms
  - 30+ useful aliases
  - Color configuration
  - Machine-specific overrides support

- **`.config/git/ignore`** - Global gitignore patterns
  - Operating system files (macOS, Windows, Linux)
  - Editor/IDE files (VS Code, JetBrains, Vim, Emacs, etc.)
  - Language-specific files (Python, Node.js, Ruby, Go, Rust, Java)
  - Build artifacts and dependencies
  - Environment files and secrets
  - Logs, caches, and temporary files

- **`.config/git/message`** - Commit message template
  - Conventional Commits format
  - Type definitions (feat, fix, docs, etc.)
  - 50/72 rule guidance
  - Examples and best practices

- **`.config/git/attributes`** - Git attributes (optional)
  - Line ending normalization
  - Binary file declarations
  - Diff and merge settings
  - Language-specific settings

- **`.config/git/gitconfig.local.example`** - Example machine-specific config
  - Template for `.gitconfig.local`
  - Shows 1Password configuration
  - Reference for manual setup
  - Not deployed (example only)

### Utility Scripts

- **`.local/bin/configure-git-machine`** - Configure machine-specific settings
  - Imports SSH keys from GitHub using ssh-import-id
  - Detects 1Password installation automatically
  - Configures GPG signing with appropriate program
  - Generates `.gitconfig.local` with signing key
  - Falls back to ssh-keygen if 1Password unavailable
  - Verifies configuration after setup

- **`.local/bin/git-setup-verify`** - Verify git configuration
  - Checks git installation
  - Verifies user configuration
  - Validates signing setup
  - Confirms global gitignore and template
  - Tests 1Password integration
  - Lists configured aliases

- **`.local/bin/git-create-repo-template`** - Create new repository
  - Initializes git repository
  - Creates .gitignore
  - Creates README.md template
  - Makes initial commit
  - Follows best practices

## Installation

### Prerequisites

Git must be installed on your system:

```bash
# Debian/Ubuntu
sudo apt-get install git

# Arch Linux
sudo pacman -S git

# macOS (Homebrew)
brew install git
```

### Deployment

This module is deployed via the main `install.sh` script:

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

After deployment:
1. Configure machine-specific settings: `configure-git-machine <github-username>`
2. Verify configuration: `git-setup-verify`
3. Check user identity: `git config user.name && git config user.email`
4. Test an alias: `git s` (short status)

## Key Features

### SSH-Based Commit Signing with 1Password

Commits are signed using SSH keys managed by 1Password:

```ini
[commit]
    gpgSign = true

[gpg]
    format = ssh

[gpg "ssh"]
    program = /opt/1Password/op-ssh-sign
```

**Benefits**:
- More secure than GPG
- Simpler key management
- Integrated with 1Password
- SSH keys you already use

**Quick Setup**:
```bash
# Automated setup (recommended)
configure-git-machine <your-github-username>
```

The script will:
1. Import your SSH keys from GitHub
2. Detect 1Password installation
3. Configure signing automatically
4. Generate `.gitconfig.local` with proper settings
5. Fall back to ssh-keygen if 1Password is not available

**Manual Setup**:
1. Ensure 1Password is installed and configured
2. Add your SSH key to 1Password
3. Configure GitHub to recognize your signing key
4. Create `.gitconfig.local` with your signing key

### Useful Git Aliases

30+ aliases for common operations:

**Status and Info**:
- `git s` - Short status
- `git br` - List branches
- `git bra` - List all branches (including remotes)

**Commits**:
- `git c "message"` - Quick commit
- `git ca` - Amend last commit
- `git cam "message"` - Commit all changes
- `git undo` - Undo last commit (keep changes)

**Logs**:
- `git l` - One-line log with graph
- `git ll` - Detailed log with all branches
- `git last` - Show last commit
- `git today` - Show commits from today
- `git week` - Show commits from this week

**Branching**:
- `git co <branch>` - Checkout branch
- `git cob <name>` - Create and checkout new branch
- `git cleanup` - Delete merged branches

**Remote Operations**:
- `git up` - Pull with rebase
- `git p` - Push current branch
- `git pf` - Force push (safely with --force-with-lease)

**See all aliases**: `git aliases`

### Global Gitignore Patterns

Comprehensive ignore patterns for:
- OS files (.DS_Store, Thumbs.db)
- Editor config (.vscode/, .idea/)
- Dependencies (node_modules/, vendor/)
- Build outputs (dist/, target/, build/)
- Environment files (.env, .env.local)
- Logs and caches (*.log, .cache/)
- Python artifacts (__pycache__/, *.pyc)
- And many more

### Commit Message Template

Guides you to write better commit messages:

```
feat: add new feature

Detailed explanation of what and why.

Closes #123
```

**Conventional Commits types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

### Better Diff and Merge

**Diff improvements**:
- `histogram` algorithm (better for code)
- Rename and copy detection
- Mnemonic prefixes (i/ for index, w/ for work tree)
- Color-coded moved lines

**Merge improvements**:
- `zdiff3` conflict style (shows common ancestor)
- `histogram` algorithm
- Auto-stash during rebase

**Example conflict marker with zdiff3**:
```
<<<<<<< HEAD
current version
||||||| base
original version
=======
incoming version
>>>>>>> branch
```

### Smart Pull and Push Defaults

**Pull**:
- Rebase instead of merge (cleaner history)
- Auto-stash changes before pulling
- Prune deleted remote branches

**Push**:
- Push current branch to same-named remote
- Auto-setup remote tracking
- Push tags along with commits

**Fetch**:
- Prune deleted branches and tags automatically

## Configuration Customization

### Machine-Specific Overrides

The `.gitconfig.local` file contains machine-specific settings and is NOT version controlled. This is perfect for:
- Different signing keys per machine
- 1Password vs ssh-keygen configuration
- Work vs personal email addresses
- Machine-specific editor preferences

**Automatic Generation**:
```bash
# Generate .gitconfig.local automatically
configure-git-machine <github-username>
```

**Manual Creation**:
Create `~/.gitconfig.local` manually (see `~/.config/git/gitconfig.local.example` for reference):

```ini
# ~/.gitconfig.local

[user]
    signingKey = ssh-ed25519 AAAAC3Nza...  # Your SSH public key

[gpg]
    format = ssh

[gpg "ssh"]
    program = /opt/1Password/op-ssh-sign  # or /usr/bin/ssh-keygen

[core]
    editor = nvim  # Override default editor

[user]
    email = work@example.com  # Override email for work machine
```

An example file is provided at `~/.config/git/gitconfig.local.example` after deployment. This file is automatically included in the main `.gitconfig` and not version controlled.

### Add Custom Aliases

```bash
# Add to ~/.gitconfig.local
[alias]
    # Your custom aliases
    praise = blame
    please = push --force-with-lease
    commend = commit --amend --no-edit
```

### Disable Commit Signing (if needed)

```bash
# In ~/.gitconfig.local
[commit]
    gpgsign = false
```

## Usage Examples

### Basic Workflow

```bash
# Clone repository
git clone <url>
cd repo

# Create feature branch
git cob feature/new-feature

# Make changes and commit
git a  # Add interactively
git c "feat: add new feature"

# Update from main
git co main
git up  # Pull with rebase

# Merge feature
git co feature/new-feature
git rebase main
git co main
git merge feature/new-feature

# Push changes
git p
```

### Using Commit Template

```bash
git commit
# Opens editor with template

# Fill in:
feat: add user authentication

Implement JWT-based authentication system with
token refresh and role-based access control.

- Add login/logout endpoints
- Implement JWT middleware
- Add user role management

Closes #42
```

### Checking Configuration

```bash
# Verify entire setup
git-setup-verify

# Check specific settings
git config user.name
git config user.email
git config commit.gpgsign

# List all configuration
git config --list
```

### Creating New Repository

```bash
# Use helper script
git-create-repo-template my-new-project
cd my-new-project

# Already initialized with:
# - .gitignore
# - README.md
# - Initial commit
```

### Cleaning Up Branches

```bash
# List merged branches
git branch --merged

# Delete merged branches (except main/master)
git cleanup

# Force delete unmerged branch
git brD feature/abandoned
```

## Improvements Over Default Git

1. **Better Defaults**:
   - Pull with rebase (cleaner history)
   - Auto-setup remote tracking
   - Prune deleted branches automatically
   - Default branch is `main`

2. **Enhanced Output**:
   - Better diff algorithm (histogram)
   - Color-coded status and diff
   - One-line log with graph
   - Relative dates in logs

3. **Commit Quality**:
   - Commit message template
   - Verbose commits (show diff)
   - Automatic signing with SSH

4. **Time-Saving Aliases**:
   - 30+ shortcuts for common operations
   - Semantic names (s, co, br, etc.)
   - Advanced operations (cleanup, today, week)

5. **Better Conflicts**:
   - zdiff3 conflict style (shows ancestor)
   - Histogram merge algorithm
   - Auto-stash during rebase

6. **Global Patterns**:
   - Comprehensive gitignore
   - Consistent line endings
   - Language-specific handling

## Troubleshooting

### Commit Signing Fails

```bash
# Verify 1Password is installed
which op

# Check if authenticated
op account list

# Test signing
echo "test" | ssh-keygen -Y sign -n test -f ~/.ssh/id_ed25519

# Fallback: use ssh-keygen
git config --global gpg.ssh.program /usr/bin/ssh-keygen
```

### Global Gitignore Not Working

```bash
# Verify path
git config core.excludesfile

# Check file exists
cat ~/.config/git/ignore

# Test with specific file
git check-ignore -v node_modules/
```

### Alias Not Found

```bash
# List all aliases
git config --get-regexp alias

# Or use the alias
git aliases

# Check specific alias
git config alias.s
```

### Pull Rebase Conflicts

```bash
# If rebase causes issues, abort
git rebase --abort

# Use merge instead for this pull
git pull --no-rebase

# Or disable rebase permanently in ~/.gitconfig.local
[pull]
    rebase = false
```

## Security Considerations

### Commit Signing

- All commits signed by default with SSH key
- 1Password manages signing key securely
- GitHub verifies signatures with "Verified" badge

### Global Gitignore

- Prevents accidentally committing secrets (.env files)
- Excludes sensitive files (*.key, *.pem)
- Catches common credential files

### Machine-Specific Data

- `.gitconfig.local` not version controlled
- Signing key path can be overridden
- Email can be different per machine

## Resources

- **Git Documentation**: https://git-scm.com/doc
- **Conventional Commits**: https://www.conventionalcommits.org/
- **1Password SSH Agent**: https://developer.1password.com/docs/ssh/
- **Git Aliases**: https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases

## Module Configuration

Deployed to hosts: `HOME-DESKTOP`

Module structure:
```
git/
├── .gitconfig                           # Main configuration
├── .config/git/
│   ├── ignore                           # Global gitignore
│   ├── message                          # Commit template
│   ├── attributes                       # Git attributes
│   └── gitconfig.local.example          # Example machine-specific config
├── .local/bin/
│   ├── configure-git-machine            # Machine setup script
│   ├── git-setup-verify                 # Configuration checker
│   └── git-create-repo-template         # Repository creator
└── README.md                            # This file
```
