---
layout: default
title: "SSH Configuration"
parent: Modules
---

# SSH Module

Base SSH configuration with modular host management via `config.d/` includes.

## Overview

This module provides a structured SSH configuration including:
- Base config with `Include config.d/*` for modular host management
- GitHub host entry (port 443 for firewall-restricted networks)
- Example host entries from previous setups as a reference
- Allowed signers file for SSH signature verification
- Proper permissions setup via configure-ssh script

## What's Included

### Configuration Files

- **`.ssh/config`** - Base SSH configuration
  - Includes all files from `config.d/`
  - `AddKeysToAgent yes` for automatic key loading
  - Commented 1Password SSH agent configuration (Linux and macOS)

- **`.ssh/config.d/github`** - GitHub host entry (deployed)
  - Uses `ssh.github.com` on port 443 (works through firewalls)
  - ed25519 key authentication

- **`.ssh/config.d/hosts.example`** - Example hosts (NOT deployed)
  - Reference entries for home lab, servers, and jump hosts
  - Copy and customize for your environment
  - Excluded from stow via `.stow-local-ignore`

- **`.ssh/allowed_signers`** - SSH signature verification
  - Maps identities to public keys for `git log --show-signature`

### Utility Scripts

- **`configure-ssh`** - Permissions and setup script
  - Creates `config.d/` directory if missing
  - Sets correct permissions (700 for .ssh, 600 for configs/keys, 644 for pub keys)
  - Prints next steps for key generation and host setup

## Setup

### Deployment

This module is deployed via the main `install.sh` script:

```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

After deployment, set permissions:

```bash
configure-ssh
```

### Adding Host Entries

1. Copy entries from the example file:
   ```bash
   cp ~/.ssh/config.d/hosts.example ~/.ssh/config.d/my-hosts
   ```

2. Edit hostnames, IPs, and users to match your environment:
   ```bash
   nvim ~/.ssh/config.d/my-hosts
   ```

3. Verify with:
   ```bash
   ssh -G <hostname>
   ```

### 1Password SSH Agent

Uncomment the appropriate line in `~/.ssh/config`:

```
# Linux:
IdentityAgent ~/.1password/agent.sock

# macOS:
IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

### Generate SSH Key

If you don't have an SSH key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

## Security

### Permissions Model

| Path | Permission | Description |
|------|-----------|-------------|
| `~/.ssh/` | 700 | Directory accessible only by owner |
| `~/.ssh/config` | 600 | Base config (owner read/write) |
| `~/.ssh/config.d/*` | 600 | Host configs (owner read/write) |
| `~/.ssh/id_*` | 600 | Private keys (owner read/write) |
| `~/.ssh/id_*.pub` | 644 | Public keys (world readable) |
| `~/.ssh/allowed_signers` | 644 | Signature verification (world readable) |

### What's Tracked vs Not

| Tracked (in dotfiles) | Not Tracked |
|-----------------------|-------------|
| Base config | Private keys |
| config.d/github | Custom host files |
| hosts.example | 1Password agent socket |
| allowed_signers | authorized_keys |

The `hosts.example` file is tracked in the repo but excluded from stow deployment, so `Include config.d/*` won't accidentally parse example entries.

## Module Configuration

Deployed to hosts: `HOME-DESKTOP`, `ASUS-LAPTOP`, `WORK-MACBOOK`, `CODESPACES`

Module structure:
```
ssh/
├── .ssh/
│   ├── config
│   ├── config.d/
│   │   ├── github
│   │   └── hosts.example    (excluded from stow)
│   └── allowed_signers
├── .local/bin/
│   └── configure-ssh
└── .stow-local-ignore
```
