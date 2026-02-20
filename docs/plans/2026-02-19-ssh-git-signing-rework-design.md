# SSH + Git Signing Rework Design

## Summary

Rework the git and SSH modules to cleanly separate base configuration from machine-specific identity/signing setup. The base `.gitconfig` becomes portable (no hardcoded identity), and a reworked `configure-git-machine` script auto-detects 1Password, fetches identity from GitHub, and generates `.gitconfig.local` with signing config.

## Modules Affected

- **git/** -- base `.gitconfig` change, reworked `configure-git-machine` script, updated `.gitconfig.local.example`
- **ssh/** -- `allowed_signers` becomes a seed file, `configure-ssh` stays focused on permissions

## Changes

### 1. Base `.gitconfig`

Remove the `[user]` section (name, email). Identity is handled exclusively by `.gitconfig.local`, generated per-machine by `configure-git-machine`. The existing `[include] path = ~/.gitconfig.local` already handles the include.

Everything else in `.gitconfig` (aliases, core settings, commit template, pull/push config, safe directories) stays unchanged.

### 2. `configure-git-machine` (Reworked)

**Location:** `git/.local/bin/configure-git-machine`
**Usage:** `configure-git-machine <github_username>`

Idempotent pipeline with these steps:

1. **Validate input** -- require exactly one argument (GitHub username)
2. **Fetch user identity** -- `GET https://api.github.com/users/<username>` to get `name`; construct email as `<username>@users.noreply.github.com`
3. **Fetch SSH keys** -- `GET https://github.com/<username>.keys`; select first `ssh-ed25519` key (fall back to first key if no ed25519)
4. **Detect 1Password agent socket:**
   - Linux: `~/.1password/agent.sock`
   - macOS: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
   - If socket exists: set signing program to `op-ssh-sign` (auto-detect path per platform)
   - If no socket: fall back to `/usr/bin/ssh-keygen`
5. **Generate `~/.gitconfig.local`** -- backup existing with timestamp, write:
   - `[user]` name, email, signingKey
   - `[gpg]` format = ssh
   - `[gpg "ssh"]` program, allowedSignersFile
6. **Update `~/.ssh/allowed_signers`** -- for each fetched key, check if already present; append only new ones prefixed with GitHub username

Output: colored status messages at each step, summary at end.

### 3. `configure-ssh` (Unchanged Scope)

Stays focused on SSH directory structure and permissions:
- `~/.ssh` at 700
- Config files at 600
- `.pub` files at 644
- Structure validation and status output

### 4. `allowed_signers` Seed File

The stowed `ssh/.ssh/allowed_signers` becomes a seed with a comment header explaining the format. `configure-git-machine` appends keys fetched from GitHub that are not already present.

### 5. `.gitconfig.local.example` Update

Updated to match the new generated format (user identity + SSH signing config + 1Password detection notes).

### 6. Removals

- `[user]` section from base `.gitconfig`

### 7. Unchanged

- `configure-ssh` (SSH permissions only)
- `1password-ssh-init` (agent startup)
- `opkey` (key loading helper)
- Shell agent integrations (bash/zsh/fish `70-ssh-agent.*`)
- SSH `config.d/` structure (1password, github, hosts.example)
- `git-create-repo-template`, `git-setup-verify`

## Platform Support

1Password socket detection covers:
- Linux: `~/.1password/agent.sock`, signing at `/opt/1Password/op-ssh-sign`
- macOS: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`, signing at `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`

## Design Principles

- **Idempotent:** safe to run repeatedly, backs up before overwriting
- **Convention over configuration:** auto-detects everything from GitHub username
- **Graceful fallback:** works without 1Password (uses ssh-keygen)
- **Append-only signers:** preserves manually-added allowed_signers entries
