---
layout: default
title: "1Password Integration"
---

# 1Password Integration for Direnv

Integration of 1Password CLI with direnv for automatic secret loading.

## Overview

The 1Password integration allows you to store secret references (like `op://vault/item/field`) in `.env` or `.oprc` files, which are automatically resolved and loaded into your environment when entering a directory.

## Files Created

### Core Layout
- **`layout-1password.sh`** - Main 1Password integration layout library
  - `layout_op` - Load secrets from .oprc or .env with op:// references
  - `layout_env_op` - Combined regular env vars (.env) + secrets (.oprc)

### Helper Script
- **`direnv-init-1password`** - Quick setup script
  - Creates `.envrc` with 1Password layout
  - Generates `.oprc` template with examples
  - Adds `.oprc` to `.gitignore`
  - Runs `direnv allow` automatically

## Prerequisites

1. **1Password CLI installed**:
   ```bash
   # Already installed at /usr/bin/op (version 2.32.0)
   # Or install: brew install --cask 1password-cli
   ```

2. **Authenticated with 1Password**:
   ```bash
   eval $(op signin)
   ```

## Quick Start

### Option 1: Using Helper Script (Recommended)

```bash
cd /path/to/your/project
direnv-init-1password

# Edit .oprc and add your secrets
# Example: DATABASE_PASSWORD=op://Private/mydb/password

cd .  # Reload environment
echo $DATABASE_PASSWORD  # Verify secret is loaded
```

### Option 2: Manual Setup

```bash
# Create .oprc with secret references
cat > .oprc << 'EOF'
DATABASE_URL=op://vault-name/database/connection-url
API_KEY=op://vault-name/api-credentials/api-key
EOF

# Create .envrc
echo 'layout op' > .envrc

# Add .oprc to .gitignore
echo '.oprc' >> .gitignore

# Allow and test
direnv allow
cd .
```

## Usage Patterns

### Dedicated Secrets File (.oprc)

Best practice - separate secrets from regular environment variables:

```bash
# .oprc - 1Password secrets (never commit)
DATABASE_PASSWORD=op://production/postgres/password
STRIPE_SECRET_KEY=op://production/stripe/secret-key
JWT_SECRET=op://production/auth/jwt-secret

# .envrc
layout op
```

### Combined Regular Vars + Secrets

Use both .env for regular vars and .oprc for secrets:

```bash
# .env - Regular environment variables (can commit)
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug

# .oprc - 1Password secrets (never commit)
DATABASE_PASSWORD=op://dev/postgres/password
API_KEY=op://dev/external-api/key

# .envrc
layout env_op      # Load .env first, then .oprc secrets
```

### With Language Layouts

Combine with Python, Node.js, or other layouts:

```bash
# .envrc
layout python      # Set up Python virtual environment
layout op          # Load 1Password secrets

# Or
layout uv          # Python with UV
layout env_op      # Load .env + .oprc secrets
```

### Using .env with op:// References

If you prefer a single file:

```bash
# .env (contains both regular vars and op:// references)
NODE_ENV=development
DATABASE_URL=op://dev/postgres/url
API_KEY=op://dev/api/key

# .envrc
layout op          # Automatically processes op:// in .env
```

## Secret Reference Syntax

1Password secret references use the format:

```
op://[vault-name]/[item-name]/[field-name]
```

**Examples**:
```bash
# Password field from database item in production vault
DATABASE_PASSWORD=op://production/database/password

# API key from api-credentials item in development vault
API_KEY=op://development/api-credentials/api-key

# SSH private key from ssh-key item in personal vault
SSH_KEY=op://personal/ssh-key/private-key

# Custom field from item
WEBHOOK_SECRET=op://vault/item/webhook-secret
```

## Features

### Automatic Secret Resolution
- Reads `op://` references and replaces with actual values
- Exports secrets as environment variables
- Only accessible when authenticated with 1Password

### File Priority
1. Checks for `.oprc` first (dedicated secrets file)
2. Falls back to `.env` if it contains `op://` references
3. Gracefully handles missing files (no error if neither exists)

### Error Handling
- Checks if `op` CLI is installed with helpful message
- Verifies authentication before loading secrets
- Reports failed secret loads but continues with others
- Clear error messages with resolution steps

### Mixed Content Support
- Can handle both regular env vars and `op://` references in same file
- Processes comments and empty lines correctly
- Removes quotes from values automatically

## Security Best Practices

1. **Never commit secret files**:
   ```bash
   # Always in .gitignore
   .oprc
   .env
   .envrc.local
   ```

2. **Use .oprc for secrets**: Separate from regular env vars in .env

3. **Commit .env.example**: Template for required variables
   ```bash
   # .env.example (safe to commit)
   DATABASE_URL=op://vault/db/url
   API_KEY=op://vault/api/key
   ```

4. **Direnv auto-approval**: Only works in trusted directories (from direnv.toml)

5. **Authentication required**: Secrets only accessible when signed in to 1Password

6. **Machine-specific overrides**: Use `.envrc.local` for non-secret overrides

## Testing

Test environment created at: `/tmp/test-1password-direnv`

Files created:
- `.envrc` - Contains `layout op`
- `.oprc` - Template with example secret references
- `.gitignore` - Contains `.oprc`

## Troubleshooting

### Op CLI not found
```bash
# Install 1Password CLI
brew install --cask 1password-cli

# Or download from: https://developer.1password.com/docs/cli/get-started/
```

### Not authenticated
```bash
# Sign in to 1Password
eval $(op signin)

# Verify authentication
op account list
```

### Secret not loading
```bash
# Check secret reference syntax
op read "op://vault-name/item-name/field-name"

# Verify direnv is working
direnv status

# Check for errors
cd .  # Reload and watch for error messages
```

### Layout not found
```bash
# Verify layout file is deployed
ls -l ~/.config/direnv/lib/layout-1password.sh

# Check if direnvrc loads the library
grep "layout-1password" ~/.config/direnv/direnvrc
```

## Examples

### Python Project with Secrets
```bash
cd ~/Projects/my-python-app
direnv-init-python

# Add secrets
cat >> .oprc << 'EOF'
DATABASE_URL=op://dev/postgres/url
REDIS_URL=op://dev/redis/url
SECRET_KEY=op://dev/django/secret-key
EOF

# Update .envrc to load secrets
cat >> .envrc << 'EOF'

# Load 1Password secrets
layout op
EOF

direnv allow
cd .  # Reload
```

### Node.js API with Secrets
```bash
cd ~/Projects/my-api

# Create environment setup
cat > .env << 'EOF'
NODE_ENV=development
PORT=3000
EOF

cat > .oprc << 'EOF'
DATABASE_PASSWORD=op://dev/postgres/password
JWT_SECRET=op://dev/auth/jwt-secret
STRIPE_SECRET_KEY=op://dev/stripe/secret-key
EOF

cat > .envrc << 'EOF'
layout nodejs
layout env_op
EOF

echo '.oprc' >> .gitignore
echo '.env' >> .gitignore

direnv allow
cd .  # Reload
```

### Multi-Environment Setup
```bash
# .envrc
layout env_op

# Load environment-specific secrets
if [[ "$ENVIRONMENT" == "production" ]]; then
    export DATABASE_URL="$(op read 'op://production/database/url')"
else
    export DATABASE_URL="$(op read 'op://dev/database/url')"
fi
```

## Integration with Existing Layouts

The 1Password layout integrates seamlessly with existing direnv layouts:

- **Python**: `layout python` or `layout uv` + `layout op`
- **Node.js**: `layout nodejs` + `layout op`
- **Go**: `layout golang` + `layout op`
- **Rust**: `layout rust` + `layout op`
- **Auto**: `layout env_op` (combines env loading + secrets)

## Implementation Details

### Layout Functions

**`layout_op`**:
- Checks for `op` CLI installation
- Verifies authentication with 1Password
- Looks for `.oprc` first, then `.env` with `op://` references
- Processes each line for `op://` references
- Exports secrets as environment variables
- Handles both secrets and regular env vars

**`layout_env_op`**:
- Calls `dotenv_if_exists .env` to load regular vars
- Calls `layout_op` to load secrets from `.oprc`
- Sources `.envrc.local` for machine-specific overrides
- Provides combined loading pattern

### File Processing

1. Reads file line by line
2. Skips empty lines and comments
3. Matches `VAR_NAME=op://...` pattern
4. Calls `op read` to resolve secret
5. Exports as environment variable
6. Logs success/failure per secret

### Auto-Loading

The layout is automatically available because:
1. `direnvrc` sources all `layout-*.sh` files in `lib/`
2. `layout-1password.sh` defines `layout_op` and `layout_env_op`
3. Functions are available in any `.envrc` file

## Documentation Updates

Documentation added to:
- `direnv/README.md` - Main module documentation
- `direnv/.config/direnv/lib/README.md` - Library structure
- `direnv/1PASSWORD.md` - This file (detailed integration guide)

## Verification

Test the integration:

```bash
cd /tmp/test-1password-direnv
cat .envrc
cat .oprc
cat .gitignore

# Test with a real secret (if you have one)
# Edit .oprc and add: TEST_VAR=op://vault/item/field
# cd .
# echo $TEST_VAR
```

Clean up test:
```bash
rm -rf /tmp/test-1password-direnv
```
