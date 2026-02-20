# SSH + Git Signing Rework Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rework git/ssh modules so the base `.gitconfig` is portable (no hardcoded identity) and `configure-git-machine` auto-detects 1Password, fetches identity from GitHub, and generates `.gitconfig.local` with SSH signing config.

**Architecture:** Two scripts with distinct responsibilities. `configure-ssh` handles SSH directory permissions. `configure-git-machine` is an idempotent pipeline that takes a GitHub username, fetches identity + keys from GitHub API, detects 1Password agent socket (cross-platform), generates `.gitconfig.local`, and updates `~/.ssh/allowed_signers` (append-only).

**Tech Stack:** Bash scripts, GitHub API (unauthenticated), GNU Stow, curl, jq (optional, fallback to grep)

---

### Task 1: Remove `[user]` section from base `.gitconfig`

**Files:**
- Modify: `git/.gitconfig:4-6`

**Step 1: Remove the `[user]` block**

Delete lines 4-6 from `git/.gitconfig`:

```diff
- [user]
-     name = Anirudh Aggarwal
-     email = 16053724+ani1797@users.noreply.github.com
-
```

The file should go directly from the header comment (line 2) to the `[core]` section. Keep the blank line before `[core]`.

**Step 2: Verify the file is valid**

Run: `git -c include.path=/dev/null config --file git/.gitconfig --list`
Expected: no `user.name` or `user.email` in output, no parse errors.

**Step 3: Commit**

```bash
git add git/.gitconfig
git commit -m "refactor(git): remove hardcoded user identity from base gitconfig

Identity is now managed exclusively via ~/.gitconfig.local,
generated per-machine by configure-git-machine."
```

---

### Task 2: Update `allowed_signers` seed file

**Files:**
- Modify: `ssh/.ssh/allowed_signers`

**Step 1: Add comment header to the seed file**

Replace the contents of `ssh/.ssh/allowed_signers` with:

```
# SSH Allowed Signers
# Format: <identifier> <key-type> <public-key>
# Managed by configure-git-machine — new keys are appended automatically.
# Manual entries are preserved across runs.
#
# See: https://man.archlinux.org/man/ssh-keygen.1#ALLOWED_SIGNERS
```

Remove the existing hardcoded key line. The file becomes a seed with documentation only; actual keys are added by `configure-git-machine` at runtime.

**Step 2: Commit**

```bash
git add ssh/.ssh/allowed_signers
git commit -m "refactor(ssh): convert allowed_signers to documented seed file

Keys are now appended by configure-git-machine at runtime.
Manual entries are preserved across script runs."
```

---

### Task 3: Rewrite `configure-git-machine` script

**Files:**
- Modify: `git/.local/bin/configure-git-machine`

**Step 1: Write the new script**

Replace the entire contents of `git/.local/bin/configure-git-machine` with the following. The script is an idempotent pipeline with 6 discrete functions:

```bash
#!/usr/bin/env bash
# configure-git-machine — set up machine-specific git identity and SSH signing
#
# Usage: configure-git-machine <github_username>
#
# Pipeline:
#   1. Fetch user identity from GitHub API
#   2. Fetch SSH public keys from GitHub
#   3. Detect 1Password SSH agent (cross-platform)
#   4. Generate ~/.gitconfig.local (backup existing)
#   5. Update ~/.ssh/allowed_signers (append-only)

set -euo pipefail

# ── colours ──────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}::${NC} $*"; }
ok()      { echo -e "${GREEN}✓${NC}  $*"; }
warn()    { echo -e "${YELLOW}!${NC}  $*"; }
err()     { echo -e "${RED}✗${NC}  $*" >&2; }
die()     { err "$@"; exit 1; }

# ── configuration ────────────────────────────────────────────────────
GITCONFIG_LOCAL="$HOME/.gitconfig.local"
ALLOWED_SIGNERS="$HOME/.ssh/allowed_signers"

# 1Password socket paths (platform-specific)
OP_SOCK_LINUX="$HOME/.1password/agent.sock"
OP_SOCK_MACOS="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# 1Password signing program paths
OP_SIGN_LINUX="/opt/1Password/op-ssh-sign"
OP_SIGN_MACOS="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

FALLBACK_SIGN="/usr/bin/ssh-keygen"

# ── helpers ──────────────────────────────────────────────────────────
need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

detect_platform() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       die "Unsupported platform: $(uname -s)" ;;
    esac
}

# ── pipeline steps ───────────────────────────────────────────────────

# Step 1: Fetch identity from GitHub API
fetch_identity() {
    local username="$1"
    info "Fetching identity for GitHub user: ${BOLD}$username${NC}"

    local api_response
    api_response=$(curl -sf "https://api.github.com/users/${username}") \
        || die "Failed to fetch GitHub user: $username"

    # Extract name — try jq first, fall back to grep
    if command -v jq >/dev/null 2>&1; then
        GIT_NAME=$(echo "$api_response" | jq -r '.name // empty')
    else
        GIT_NAME=$(echo "$api_response" | grep -oP '"name"\s*:\s*"\K[^"]+' || true)
    fi

    if [[ -z "$GIT_NAME" ]]; then
        die "GitHub user '$username' has no public name set"
    fi

    GIT_EMAIL="${username}@users.noreply.github.com"

    ok "Name:  $GIT_NAME"
    ok "Email: $GIT_EMAIL"
}

# Step 2: Fetch SSH keys from GitHub
fetch_keys() {
    local username="$1"
    info "Fetching SSH keys from github.com/${username}.keys"

    GITHUB_KEYS=$(curl -sf "https://github.com/${username}.keys") \
        || die "Failed to fetch SSH keys for: $username"

    if [[ -z "$GITHUB_KEYS" ]]; then
        die "No SSH keys found for GitHub user: $username"
    fi

    local key_count
    key_count=$(echo "$GITHUB_KEYS" | wc -l)
    ok "Found $key_count key(s)"

    # Pick signing key: prefer ed25519, fall back to first key
    SIGNING_KEY=$(echo "$GITHUB_KEYS" | grep "ssh-ed25519" | head -n1 || true)
    if [[ -z "$SIGNING_KEY" ]]; then
        warn "No ed25519 key found, using first available key"
        SIGNING_KEY=$(echo "$GITHUB_KEYS" | head -n1)
    fi

    # Strip trailing comment (keep "type base64" only)
    SIGNING_KEY=$(echo "$SIGNING_KEY" | awk '{print $1, $2}')

    ok "Signing key: ${SIGNING_KEY:0:50}..."
}

# Step 3: Detect 1Password SSH agent
detect_1password() {
    local platform="$1"
    info "Detecting 1Password SSH agent..."

    local op_sock op_sign
    if [[ "$platform" == "macos" ]]; then
        op_sock="$OP_SOCK_MACOS"
        op_sign="$OP_SIGN_MACOS"
    else
        op_sock="$OP_SOCK_LINUX"
        op_sign="$OP_SIGN_LINUX"
    fi

    if [[ -S "$op_sock" ]]; then
        ok "1Password agent socket found: $op_sock"
        if [[ -x "$op_sign" ]]; then
            GPG_SSH_PROGRAM="$op_sign"
            ok "Signing program: $GPG_SSH_PROGRAM"
        else
            warn "1Password socket exists but op-ssh-sign not found at $op_sign"
            warn "Falling back to $FALLBACK_SIGN"
            GPG_SSH_PROGRAM="$FALLBACK_SIGN"
        fi
    else
        warn "No 1Password agent socket at $op_sock"
        GPG_SSH_PROGRAM="$FALLBACK_SIGN"
        ok "Using fallback: $GPG_SSH_PROGRAM"
    fi
}

# Step 4: Generate ~/.gitconfig.local
generate_gitconfig_local() {
    info "Generating $GITCONFIG_LOCAL"

    # Backup existing
    if [[ -f "$GITCONFIG_LOCAL" ]]; then
        local backup="${GITCONFIG_LOCAL}.bak.$(date +%Y%m%d_%H%M%S)"
        cp "$GITCONFIG_LOCAL" "$backup"
        warn "Backed up existing → $backup"
    fi

    cat > "$GITCONFIG_LOCAL" << EOF
# Machine-specific Git configuration
# Generated by configure-git-machine on $(date +%Y-%m-%d)
# Do NOT check this file into version control.

[user]
    name = $GIT_NAME
    email = $GIT_EMAIL
    signingKey = $SIGNING_KEY

[gpg]
    format = ssh

[gpg "ssh"]
    program = $GPG_SSH_PROGRAM
    allowedSignersFile = $ALLOWED_SIGNERS
EOF

    ok "Written to $GITCONFIG_LOCAL"
}

# Step 5: Update allowed_signers (append-only)
update_allowed_signers() {
    local username="$1"
    info "Updating $ALLOWED_SIGNERS"

    mkdir -p "$(dirname "$ALLOWED_SIGNERS")"
    touch "$ALLOWED_SIGNERS"

    local added=0
    while IFS= read -r key; do
        [[ -z "$key" ]] && continue
        # Check if the key material (type + base64) already exists in the file
        local key_material
        key_material=$(echo "$key" | awk '{print $1, $2}')
        if ! grep -qF "$key_material" "$ALLOWED_SIGNERS" 2>/dev/null; then
            echo "$username $key_material" >> "$ALLOWED_SIGNERS"
            ((added++))
        fi
    done <<< "$GITHUB_KEYS"

    ok "Allowed signers updated ($added new key(s) added)"
}

# ── main ─────────────────────────────────────────────────────────────
main() {
    if [[ $# -ne 1 ]]; then
        echo "Usage: configure-git-machine <github_username>"
        exit 1
    fi

    local username="$1"
    local platform

    echo ""
    info "${BOLD}Git Machine Configuration${NC}"
    echo ""

    need_cmd curl
    need_cmd git

    platform=$(detect_platform)
    ok "Platform: $platform"
    echo ""

    fetch_identity "$username"
    echo ""

    fetch_keys "$username"
    echo ""

    detect_1password "$platform"
    echo ""

    generate_gitconfig_local
    echo ""

    update_allowed_signers "$username"
    echo ""

    info "${BOLD}Configuration complete!${NC}"
    echo ""
    info "Verify with:  git-setup-verify"
    info "Test commit:  git commit --allow-empty -m 'test: verify SSH signing'"
    echo ""
}

main "$@"
```

**Step 2: Ensure the script is executable**

Run: `chmod +x git/.local/bin/configure-git-machine`
(It already should be, but confirm.)

**Step 3: Verify syntax**

Run: `bash -n git/.local/bin/configure-git-machine`
Expected: no output (clean parse).

**Step 4: Commit**

```bash
git add git/.local/bin/configure-git-machine
git commit -m "feat(git): rewrite configure-git-machine with full pipeline

- Fetches identity (name/email) from GitHub API
- Fetches SSH keys and selects ed25519 for signing
- Cross-platform 1Password agent socket detection (Linux + macOS)
- Generates ~/.gitconfig.local with identity + signing config
- Appends new keys to ~/.ssh/allowed_signers (preserves existing)"
```

---

### Task 4: Update `.gitconfig.local.example`

**Files:**
- Modify: `git/.config/git/gitconfig.local.example`

**Step 1: Update the example to match generated format**

Replace the contents of `git/.config/git/gitconfig.local.example` with:

```
# Machine-specific Git configuration
# Generated by configure-git-machine — or create manually from this template.
# Do NOT check this file into version control.
#
# Usage: configure-git-machine <github_username>

[user]
    name = Your Name
    email = username@users.noreply.github.com
    signingKey = ssh-ed25519 AAAA...

[gpg]
    format = ssh

[gpg "ssh"]
    # 1Password (auto-detected by configure-git-machine):
    #   Linux:  /opt/1Password/op-ssh-sign
    #   macOS:  /Applications/1Password.app/Contents/MacOS/op-ssh-sign
    # Fallback (no 1Password):
    #   /usr/bin/ssh-keygen
    program = /opt/1Password/op-ssh-sign
    allowedSignersFile = ~/.ssh/allowed_signers
```

**Step 2: Commit**

```bash
git add git/.config/git/gitconfig.local.example
git commit -m "docs(git): update gitconfig.local.example to match new generated format"
```

---

### Task 5: Update `git-setup-verify` to check new config

**Files:**
- Modify: `git/.local/bin/git-setup-verify:32-43`

**Step 1: Add allowed_signers check**

After the "Commit Signing" section (around line 83), add a check for the allowed signers file:

```bash
# Check allowed signers
echo "Allowed Signers:"
if git config gpg.ssh.allowedsignersfile >/dev/null 2>&1; then
    signers_file=$(git config gpg.ssh.allowedsignersfile)
    signers_file="${signers_file/#\~/$HOME}"
    if [[ -f "$signers_file" ]]; then
        signer_count=$(grep -cv '^\s*#\|^\s*$' "$signers_file" 2>/dev/null || echo 0)
        success "Allowed signers file: $signers_file ($signer_count entries)"
    else
        error "Allowed signers file not found: $signers_file"
    fi
else
    warn "Allowed signers file not configured"
fi
echo
```

**Step 2: Update the user config check to warn about missing `.gitconfig.local`**

At the top of the "User Configuration" section (line 32), add before the name check:

```bash
if [[ -f "$HOME/.gitconfig.local" ]]; then
    success "Machine config: ~/.gitconfig.local"
else
    warn "No ~/.gitconfig.local found. Run: configure-git-machine <github_username>"
fi
```

**Step 3: Verify syntax**

Run: `bash -n git/.local/bin/git-setup-verify`
Expected: no output (clean parse).

**Step 4: Commit**

```bash
git add git/.local/bin/git-setup-verify
git commit -m "feat(git): add allowed_signers and gitconfig.local checks to verify script"
```

---

### Task 6: Verify end-to-end

**Step 1: Run shellcheck on both scripts**

Run: `shellcheck git/.local/bin/configure-git-machine git/.local/bin/git-setup-verify`
Expected: no errors (warnings acceptable for intentional patterns).

**Step 2: Dry-run test configure-git-machine**

This verifies the GitHub API calls and key parsing work. Run from the repo:

Run: `bash git/.local/bin/configure-git-machine ani1797`

Expected output:
- Platform detected (linux)
- Name and email fetched from GitHub
- SSH keys found
- 1Password agent detected (or fallback)
- `~/.gitconfig.local` generated
- `~/.ssh/allowed_signers` updated

**Step 3: Verify generated config**

Run: `cat ~/.gitconfig.local`
Expected: contains `[user]` with name, email, signingKey; `[gpg]` with format=ssh; `[gpg "ssh"]` with program and allowedSignersFile.

Run: `cat ~/.ssh/allowed_signers`
Expected: contains key entries prefixed with `ani1797`.

**Step 4: Run git-setup-verify**

Run: `git-setup-verify`
Expected: all checks pass (green checkmarks for name, email, signing key, GPG format, SSH program, allowed signers).

**Step 5: Test a signed commit**

Run: `git commit --allow-empty -m "test: verify SSH signing works"`
Expected: commit succeeds without signing errors.

Run: `git log --show-signature -1`
Expected: shows valid SSH signature.

**Step 6: Clean up test commit**

Run: `git reset HEAD~1`

---
