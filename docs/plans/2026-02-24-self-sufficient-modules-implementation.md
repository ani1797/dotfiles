# Self-Sufficient Modules Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Simplify dotfiles architecture by making modules self-sufficient with auto-discovery, removing the redundant modules[] section from config.yaml, and using prefix-based package sources.

**Architecture:** Module metadata moves entirely into deps.yaml files (adds `provides` field, uses prefix format for aur/cargo/pip). install.sh scans directories for deps.yaml to auto-discover modules. config.yaml keeps only toolkits and machines sections.

**Tech Stack:** Bash, GNU Stow, yq (YAML processor)

---

## Phase 1: Prepare Module Migration

### Task 1: Backup Current System

**Files:**
- Read: `install.sh`
- Read: `config.yaml`
- Create: `install.sh.backup`
- Create: `config.yaml.backup`

**Step 1: Create backups**

```bash
cp install.sh install.sh.backup
cp config.yaml config.yaml.backup
```

**Step 2: Verify backups exist**

```bash
ls -lh install.sh.backup config.yaml.backup
```

Expected: Both files exist with same size as originals

**Step 3: Commit backups**

```bash
git add install.sh.backup config.yaml.backup
git commit -m "chore: backup install.sh and config.yaml before refactor"
```

---

### Task 2: Create Module Migration Script

**Files:**
- Create: `scripts/migrate-deps-yaml.sh`

**Step 1: Create migration script**

```bash
#!/usr/bin/env bash
# migrate-deps-yaml.sh - Migrate deps.yaml to new format
# Adds top-level 'provides' field (extracted from script sections)
# Converts platform-specific scripts from top-level to inline

set -euo pipefail

MODULE_DIR="$1"

if [[ ! -f "$MODULE_DIR/deps.yaml" ]]; then
    echo "No deps.yaml in $MODULE_DIR"
    exit 0
fi

echo "Migrating $MODULE_DIR/deps.yaml..."

# Check if already migrated (has top-level 'provides' field)
if yq -e '.provides' "$MODULE_DIR/deps.yaml" >/dev/null 2>&1; then
    echo "  Already has 'provides' field, skipping"
    exit 0
fi

# Extract provides from script section if it exists
PROVIDES=$(yq -r '.script[]?.provides // empty' "$MODULE_DIR/deps.yaml" 2>/dev/null | head -1)

if [[ -n "$PROVIDES" ]]; then
    echo "  Adding provides: $PROVIDES"
    yq -i ".provides = \"$PROVIDES\"" "$MODULE_DIR/deps.yaml"
fi

echo "  Migration complete"
```

**Step 2: Make script executable**

```bash
chmod +x scripts/migrate-deps-yaml.sh
```

**Step 3: Test on one module**

```bash
# Test on git module (simple, should be no-op)
./scripts/migrate-deps-yaml.sh git/
cat git/deps.yaml
```

Expected: Script runs without error, git/deps.yaml unchanged or has provides field added

**Step 4: Commit migration script**

```bash
git add scripts/migrate-deps-yaml.sh
git commit -m "feat: add deps.yaml migration script"
```

---

### Task 3: Migrate All Module deps.yaml Files

**Files:**
- Modify: All `*/deps.yaml` files

**Step 1: Run migration on all modules**

```bash
for dir in */; do
    if [[ -f "$dir/deps.yaml" ]]; then
        ./scripts/migrate-deps-yaml.sh "$dir"
    fi
done
```

**Step 2: Review changes**

```bash
git diff --stat
git diff */deps.yaml | head -100
```

Expected: Multiple deps.yaml files modified with `provides` field added

**Step 3: Manual review of complex modules**

Check these modules that likely need manual migration:
- starship (has install scripts)
- yazi (might need cargo: prefix on Debian)
- nvim (complex dependencies)

```bash
cat starship/deps.yaml
cat yazi/deps.yaml
cat nvim/deps.yaml
```

**Step 4: Manually add provides where missing**

For modules without provides field, add appropriate binary names:

```bash
# Example for git
yq -i '.provides = "git"' git/deps.yaml

# Example for nvim
yq -i '.provides = "nvim"' nvim/deps.yaml

# Run for all modules missing provides
for dir in */; do
    if [[ -f "$dir/deps.yaml" ]]; then
        if ! yq -e '.provides' "$dir/deps.yaml" >/dev/null 2>&1; then
            module_name=$(basename "$dir")
            echo "Module $module_name missing provides field"
        fi
    fi
done
```

**Step 5: Commit migrated deps.yaml files**

```bash
git add */deps.yaml
git commit -m "feat: migrate all deps.yaml to include provides field

Add top-level provides field to all module deps.yaml files for
verification after installation. Extracted from script sections
where present, or added manually for modules without scripts.

Part of self-sufficient modules redesign.
"
```

---

### Task 4: Convert Platform Scripts to Inline Format

**Files:**
- Modify: `starship/deps.yaml` (has install scripts)
- Modify: Any other modules with `script:` section

**Step 1: Find modules with script sections**

```bash
for dir in */; do
    if [[ -f "$dir/deps.yaml" ]]; then
        if yq -e '.script' "$dir/deps.yaml" >/dev/null 2>&1; then
            echo "Has script: $dir"
        fi
    fi
done
```

**Step 2: Manually convert starship/deps.yaml**

```yaml
# OLD format
provides: starship

packages:
  arch:
    - starship
  debian: []
  fedora: []
  macos:
    - starship

script:
  - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
    provides: starship

# NEW format
provides: starship

packages:
  arch:
    - starship
  debian:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  fedora:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  macos:
    - starship
```

Edit `starship/deps.yaml`:

```bash
cat > starship/deps.yaml << 'EOF'
provides: starship

packages:
  arch:
    - starship
  debian:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  fedora:
    - run: "curl -sS https://starship.rs/install.sh | sh -s -- --yes"
      provides: starship
  macos:
    - starship
EOF
```

**Step 3: Convert other modules with scripts**

Repeat for each module found in Step 1, moving script entries into appropriate platform sections.

**Step 4: Verify no top-level script sections remain**

```bash
for dir in */; do
    if [[ -f "$dir/deps.yaml" ]]; then
        if yq -e '.script' "$dir/deps.yaml" >/dev/null 2>&1; then
            echo "Still has top-level script: $dir"
        fi
    fi
done
```

Expected: No output (all scripts moved to platform sections)

**Step 5: Commit script format changes**

```bash
git add */deps.yaml
git commit -m "feat: convert install scripts to platform-specific inline format

Move script entries from top-level script: section into platform-specific
packages: arrays. Scripts now inline with package lists per platform.

Example: starship script moved into debian/fedora packages arrays.

Part of self-sufficient modules redesign.
"
```

---

## Phase 2: Simplify config.yaml

### Task 5: Remove modules[] Section

**Files:**
- Modify: `config.yaml:3-59`

**Step 1: Verify current structure**

```bash
yq -r '.modules | length' config.yaml
```

Expected: Should show count of modules (around 28)

**Step 2: Create simplified config.yaml**

```bash
# Keep only toolkits and machines sections
yq -y '{toolkits: .toolkits, machines: .machines}' config.yaml > config.yaml.new
mv config.yaml.new config.yaml
```

**Step 3: Verify simplified config**

```bash
yq -r 'keys' config.yaml
```

Expected: Output should be `["toolkits", "machines"]` only

**Step 4: View diff**

```bash
git diff config.yaml
```

Expected: modules[] section (lines 3-59) removed

**Step 5: Commit simplified config**

```bash
git add config.yaml
git commit -m "feat: remove modules[] section from config.yaml

Modules are now auto-discovered from directories containing deps.yaml.
No need to declare modules in config.yaml - single source of truth
is each module's own directory.

Keeps only toolkits and machines sections.

Part of self-sufficient modules redesign.
"
```

---

## Phase 3: Rewrite install.sh

### Task 6: Update Prerequisite Check Function

**Files:**
- Modify: `install.sh:362-400` (check_core_utilities)
- Modify: `install.sh:406-446` (self_bootstrap)

**Step 1: Rewrite prerequisite check**

Replace `check_core_utilities()` and `self_bootstrap()` with:

```bash
# ============================================================================
# PREREQUISITE CHECK AND AUTO-INSTALL
# ============================================================================

check_and_install_prerequisites() {
    info "Checking prerequisites..."

    # Check core utilities (fail-fast if missing)
    local -a missing_core=()
    for cmd in stow yq git find grep sed date mkdir cp rm; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_core+=("$cmd")
        fi
    done

    if [[ ${#missing_core[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_core[*]}"
        error "Install via your package manager:"
        case "$PKG_MGR" in
            pacman) error "  sudo pacman -S stow yq git" ;;
            apt)    error "  sudo apt-get install stow yq git" ;;
            dnf)    error "  sudo dnf install stow yq git" ;;
            brew)   error "  brew install stow yq git" ;;
        esac
        exit 1
    fi

    # Check hostname command specifically
    if ! command -v hostname >/dev/null 2>&1; then
        case "$PKG_MGR" in
            pacman) missing_core+=("inetutils") ;;
            *)      missing_core+=("hostname") ;;
        esac
        error "Missing hostname command. Install: ${missing_core[*]}"
        exit 1
    fi

    # Auto-install cargo if missing
    if ! command -v cargo >/dev/null 2>&1; then
        info "Installing Rust via rustup (non-interactive, no sudo)..."
        if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
            # shellcheck source=/dev/null
            [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
            success "Cargo installed"
        else
            warn "Failed to install cargo - cargo: packages will be skipped"
        fi
    fi

    # Check Python/pip (fail-fast if missing)
    if ! command -v pip3 >/dev/null 2>&1 && ! command -v pip >/dev/null 2>&1; then
        error "Python pip not found"
        error "Install via your package manager:"
        case "$PKG_MGR" in
            pacman) error "  sudo pacman -S python-pip" ;;
            apt)    error "  sudo apt-get install python3-pip" ;;
            dnf)    error "  sudo dnf install python3-pip" ;;
            brew)   error "  brew install python3" ;;
        esac
        exit 1
    fi

    # Auto-install paru (Arch only)
    if [[ "$PKG_MGR" == "pacman" ]] && ! command -v paru >/dev/null 2>&1; then
        info "Installing paru from AUR (non-interactive)..."

        # Check for base-devel
        if ! pacman -Qq base-devel >/dev/null 2>&1; then
            warn "base-devel not installed - paru installation may fail"
            warn "Install: sudo pacman -S base-devel"
        fi

        local temp_dir
        temp_dir=$(mktemp -d)

        if git clone https://aur.archlinux.org/paru.git "$temp_dir/paru" 2>/dev/null; then
            (cd "$temp_dir/paru" && makepkg -si --noconfirm) && success "Paru installed" || warn "Paru installation failed"
            rm -rf "$temp_dir"
        else
            warn "Failed to clone paru repo - AUR packages will be skipped"
        fi
    fi

    success "Prerequisites checked"
}
```

**Step 2: Update main() to call new function**

Find the calls to `check_core_utilities` and `self_bootstrap` in `main()` and replace with single call:

```bash
# OLD (around line 1022-1029)
check_core_utilities
CURRENT_HOST="$(hostname)"
self_bootstrap

# NEW
check_and_install_prerequisites
CURRENT_HOST="$(hostname)"
```

**Step 3: Test prerequisite check**

```bash
# Dry-run to see if it parses
bash -n install.sh
```

Expected: No syntax errors

**Step 4: Commit prerequisite changes**

```bash
git add install.sh
git commit -m "feat: consolidate and improve prerequisite checks

Merge check_core_utilities() and self_bootstrap() into single
check_and_install_prerequisites() function.

Auto-install cargo via rustup and paru via makepkg when missing.
Fail-fast for tools requiring sudo (stow, yq, git).
Clearer error messages with install instructions.

Part of self-sufficient modules redesign.
"
```

---

### Task 7: Add Module Discovery Function

**Files:**
- Modify: `install.sh` (add new function after prerequisite check)

**Step 1: Add discover_modules function**

Insert after `check_and_install_prerequisites()`:

```bash
# ============================================================================
# MODULE DISCOVERY
# ============================================================================

# Discover modules by scanning for directories with deps.yaml
# Returns associative array: module_name -> directory_path
discover_modules() {
    declare -g -A DISCOVERED_MODULES

    info "Discovering modules..."

    local count=0
    while IFS= read -r -d '' deps_file; do
        local module_dir
        module_dir="$(dirname "$deps_file")"

        # Skip if not a directory
        [[ ! -d "$module_dir" ]] && continue

        # Module name = directory name
        local module_name
        module_name="$(basename "$module_dir")"

        # Store absolute path
        DISCOVERED_MODULES["$module_name"]="$module_dir"
        ((count++))
    done < <(find "$SCRIPT_DIR" -mindepth 2 -maxdepth 2 -name "deps.yaml" -print0 2>/dev/null)

    info "Discovered $count modules"

    if [[ $count -eq 0 ]]; then
        error "No modules discovered (no directories with deps.yaml found)"
        exit 1
    fi
}
```

**Step 2: Add global declaration**

Near the top of the file (after other declare statements around line 33):

```bash
declare -A DISCOVERED_MODULES
```

**Step 3: Test syntax**

```bash
bash -n install.sh
```

Expected: No syntax errors

**Step 4: Commit discovery function**

```bash
git add install.sh
git commit -m "feat: add module auto-discovery function

Add discover_modules() that scans for directories containing
deps.yaml files. Module name equals directory name.

Stores results in DISCOVERED_MODULES associative array.

Part of self-sufficient modules redesign.
"
```

---

### Task 8: Update Module Resolution Functions

**Files:**
- Modify: `install.sh:616-626` (get_module_path - remove or replace)
- Modify: `install.sh:519-613` (expand_machine_modules - update logic)

**Step 1: Remove get_module_path function**

Delete the `get_module_path()` function (no longer needed):

```bash
# Delete these lines:
get_module_path() {
    local module_name="$1"
    yq -r ".modules[] | select(.name == \"$module_name\") | .path" "$CONFIG_FILE"
}
```

**Step 2: Update expand_machine_modules**

Replace module path lookup with discovered modules lookup:

```bash
# OLD
module_path="$(get_module_path "$module_name")"
if [[ -z "$module_path" || "$module_path" == "null" ]]; then
    warn "Module '$module_name' not found in modules[] -- skipping"
    continue
fi

# NEW
if [[ -z "${DISCOVERED_MODULES[$module_name]+x}" ]]; then
    warn "Module '$module_name' not found (no directory with deps.yaml) -- skipping"
    ERRORS+=("module '$module_name' not found")
    continue
fi
```

**Step 3: Update get_module_target and get_machine_module_target**

Remove `get_module_target()` function (modules[] no longer has target field):

```bash
# Delete this function entirely:
get_module_target() {
    local module_name="$1"
    yq -r ".modules[] | select(.name == \"$module_name\") | .target // \"\"" "$CONFIG_FILE"
}
```

Update `resolve_target()` to remove module-level target check:

```bash
# OLD (around line 680-683)
# Then check module-level default
local module_target
module_target="$(get_module_target \"$module_name\")"
if [[ -n \"$module_target\" ]]; then
    eval echo \"$module_target\"
    return
fi

# NEW (remove these lines, go straight to default)
# Default to $HOME
echo "$HOME"
```

**Step 4: Update process_module function**

Replace `get_module_path` call with `DISCOVERED_MODULES` lookup:

```bash
# OLD (around line 903-910)
local module_rel_path
module_rel_path="$(get_module_path "$module_name")"

if [[ -z "$module_rel_path" || "$module_rel_path" == "null" ]]; then
    warn "Module '$module_name' not found in modules[] definitions -- skipping"
    return 0
fi

# NEW
if [[ -z "${DISCOVERED_MODULES[$module_name]+x}" ]]; then
    warn "Module '$module_name' not found -- skipping"
    ERRORS+=("module '$module_name' not found")
    return 0
fi

local module_abs_path="${DISCOVERED_MODULES[$module_name]}"
```

**Step 5: Test syntax**

```bash
bash -n install.sh
```

Expected: No syntax errors

**Step 6: Commit module resolution updates**

```bash
git add install.sh
git commit -m "feat: update module resolution to use auto-discovery

Remove get_module_path() - no longer needed (no modules[] in config).
Update expand_machine_modules() to validate against DISCOVERED_MODULES.
Remove get_module_target() - modules don't have default targets.
Update process_module() to use DISCOVERED_MODULES directly.

Part of self-sufficient modules redesign.
"
```

---

### Task 9: Update Dependency Parsing for Prefix Format

**Files:**
- Modify: `install.sh:697-793` (collect_all_dependencies)

**Step 1: Update collect_all_dependencies to parse prefixes**

Replace the dependency collection logic:

```bash
collect_all_dependencies() {
    local -a module_list=("$@")

    # Global arrays for collected dependencies
    declare -g -a ALL_NATIVE_PKGS=()
    declare -g -a ALL_AUR_PKGS=()
    declare -g -a ALL_CARGO_PKGS=()
    declare -g -a ALL_PIP_PKGS=()
    declare -g -a ALL_SCRIPTS=()
    declare -g -a ALL_REQUIRED_BINARIES=()

    local os_key
    os_key="$(get_deps_os_key "$PKG_MGR")"

    info "Collecting dependencies from ${#module_list[@]} modules..."

    local deps_files_found=0
    for module_name in "${module_list[@]}"; do
        if [[ -z "${DISCOVERED_MODULES[$module_name]+x}" ]]; then
            continue
        fi

        local module_path="${DISCOVERED_MODULES[$module_name]}"
        local deps_file="$module_path/deps.yaml"

        if [[ ! -f "$deps_file" ]]; then
            continue
        fi

        ((deps_files_found++))

        # Collect provides field for verification
        local provides
        provides="$(yq -r '.provides // empty' "$deps_file" 2>/dev/null)"
        if [[ -n "$provides" ]]; then
            # Handle both string and array formats
            if [[ "$provides" == "["* ]]; then
                # Array format
                while IFS= read -r binary; do
                    [[ -n "$binary" ]] && ALL_REQUIRED_BINARIES+=("$binary")
                done < <(yq -r '.provides[]? // empty' "$deps_file" 2>/dev/null)
            else
                # String format
                ALL_REQUIRED_BINARIES+=("$provides")
            fi
        fi

        # Parse packages for this OS
        if [[ -z "$os_key" ]]; then
            continue
        fi

        # Get count of package entries
        local pkg_count
        pkg_count="$(yq -r ".packages.${os_key} | length // 0" "$deps_file" 2>/dev/null)"

        for i in $(seq 0 $((pkg_count - 1))); do
            local entry_type
            entry_type="$(yq -r ".packages.${os_key}[$i] | type" "$deps_file" 2>/dev/null)"

            if [[ "$entry_type" == "!!str" ]] || [[ "$entry_type" == "string" ]]; then
                # String entry - parse prefix
                local pkg
                pkg="$(yq -r ".packages.${os_key}[$i]" "$deps_file" 2>/dev/null)"

                case "$pkg" in
                    aur:*)
                        ALL_AUR_PKGS+=("${pkg#aur:}")
                        ;;
                    cargo:*)
                        ALL_CARGO_PKGS+=("${pkg#cargo:}")
                        ;;
                    pip:*)
                        ALL_PIP_PKGS+=("${pkg#pip:}")
                        ;;
                    *)
                        ALL_NATIVE_PKGS+=("$pkg")
                        ;;
                esac
            else
                # Object entry - install script
                local run_cmd provides_binary
                run_cmd="$(yq -r ".packages.${os_key}[$i].run" "$deps_file" 2>/dev/null)"
                provides_binary="$(yq -r ".packages.${os_key}[$i].provides // \"\"" "$deps_file" 2>/dev/null)"

                ALL_SCRIPTS+=("$run_cmd|$provides_binary")

                if [[ -n "$provides_binary" ]]; then
                    ALL_REQUIRED_BINARIES+=("$provides_binary")
                fi
            fi
        done
    done

    info "Found $deps_files_found modules with deps.yaml"
    info "Collected: ${#ALL_NATIVE_PKGS[@]} native, ${#ALL_AUR_PKGS[@]} AUR, ${#ALL_CARGO_PKGS[@]} cargo, ${#ALL_PIP_PKGS[@]} pip, ${#ALL_SCRIPTS[@]} scripts"

    # Remove duplicates
    if [[ ${#ALL_NATIVE_PKGS[@]} -gt 0 ]]; then
        mapfile -t ALL_NATIVE_PKGS < <(printf '%s\n' "${ALL_NATIVE_PKGS[@]}" | sort -u)
    fi
    if [[ ${#ALL_AUR_PKGS[@]} -gt 0 ]]; then
        mapfile -t ALL_AUR_PKGS < <(printf '%s\n' "${ALL_AUR_PKGS[@]}" | sort -u)
    fi
    if [[ ${#ALL_CARGO_PKGS[@]} -gt 0 ]]; then
        mapfile -t ALL_CARGO_PKGS < <(printf '%s\n' "${ALL_CARGO_PKGS[@]}" | sort -u)
    fi
    if [[ ${#ALL_PIP_PKGS[@]} -gt 0 ]]; then
        mapfile -t ALL_PIP_PKGS < <(printf '%s\n' "${ALL_PIP_PKGS[@]}" | sort -u)
    fi
    if [[ ${#ALL_REQUIRED_BINARIES[@]} -gt 0 ]]; then
        mapfile -t ALL_REQUIRED_BINARIES < <(printf '%s\n' "${ALL_REQUIRED_BINARIES[@]}" | sort -u)
    fi
}
```

**Step 2: Test syntax**

```bash
bash -n install.sh
```

Expected: No syntax errors

**Step 3: Commit dependency parsing updates**

```bash
git add install.sh
git commit -m "feat: update dependency parsing for prefix format

Parse aur:, cargo:, pip: prefixes from package entries.
Parse inline script objects from platform package arrays.
Extract provides field from module deps.yaml for verification.

Handles both string and array formats for provides field.

Part of self-sufficient modules redesign.
"
```

---

### Task 10: Update main() to Use Discovery

**Files:**
- Modify: `install.sh:1000-1081` (main function)

**Step 1: Add discover_modules call**

In `main()`, after `self_bootstrap` (now `check_and_install_prerequisites`), add:

```bash
# --- Validate config.yaml ---
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Config file not found: $CONFIG_FILE"
    exit 1
fi

# --- Discover modules from directory structure ---
discover_modules

# --- Find modules for this machine ---
```

**Step 2: Remove old module listing code**

The old code tried to list available modules from config.yaml. Remove this section (it no longer makes sense):

```bash
# OLD (around line 1046-1048)
error "Available hostnames:"
yq -r '.machines[].hostname' "$CONFIG_FILE" | while read -r h; do echo "  - $h"; done

# Keep this error section, just update the message
error "Check that config.yaml has a machines[] entry with hostname: \"$CURRENT_HOST\""
error "Or add a glob pattern like \"*\" to match any hostname"
```

**Step 3: Test syntax**

```bash
bash -n install.sh
```

Expected: No syntax errors

**Step 4: Commit main() updates**

```bash
git add install.sh
git commit -m "feat: integrate module discovery into main installation flow

Call discover_modules() before module expansion.
Remove references to modules[] section in config.yaml.
Update error messages for missing modules.

Part of self-sufficient modules redesign.
"
```

---

## Phase 4: Testing and Validation

### Task 11: Dry-Run Test

**Files:**
- Test: `install.sh` (don't actually install, just validate)

**Step 1: Add dry-run mode to install.sh**

Add a DRY_RUN variable and skip actual installations:

```bash
# Near top of file (around line 24)
DRY_RUN="${DRY_RUN:-false}"

# In install functions, check DRY_RUN:
install_native_packages() {
    # ... existing code ...

    if [[ "$DRY_RUN" == "true" ]]; then
        info "  [DRY-RUN] Would install: ${missing_pkgs[*]}"
        return 0
    fi

    # ... actual install code ...
}
```

Apply to all install functions:
- `install_native_packages`
- `install_aur_packages`
- `install_cargo_packages`
- `install_pip_packages`
- Script execution in `install_all_dependencies`

**Step 2: Run dry-run test**

```bash
DRY_RUN=true ./install.sh
```

Expected:
- Discovers modules
- Parses config.yaml
- Collects dependencies
- Shows what would be installed
- Doesn't actually install anything

**Step 3: Check for errors**

Look for:
- "Module 'xyz' not found" warnings (should be zero)
- Dependency collection counts match expectations
- No bash syntax errors

**Step 4: Commit dry-run feature**

```bash
git add install.sh
git commit -m "feat: add dry-run mode for testing

Set DRY_RUN=true to validate configuration without actually
installing packages. Useful for testing configuration changes.

Usage: DRY_RUN=true ./install.sh
"
```

---

### Task 12: Test on Current System

**Files:**
- Test: Full installation on current system

**Step 1: Backup existing config**

```bash
# Backup existing dotfiles symlinks
mkdir -p /tmp/dotfiles-test-backup
for file in ~/.bashrc ~/.gitconfig ~/.config/nvim ~/.config/starship.toml; do
    if [[ -L "$file" ]]; then
        cp -L "$file" "/tmp/dotfiles-test-backup/$(basename $file)"
    fi
done
```

**Step 2: Unstow existing modules**

```bash
# Unstow all current modules
cd ~/.local/share/dotfiles
for dir in */; do
    if [[ -f "$dir/deps.yaml" ]]; then
        stow -D "$(basename $dir)" 2>/dev/null || true
    fi
done
```

**Step 3: Run new install.sh**

```bash
./install.sh 2>&1 | tee /tmp/install-test.log
```

**Step 4: Verify installation**

Check:
- Modules discovered correctly
- Dependencies installed (or skipped if already present)
- Modules stowed successfully
- No errors in summary

```bash
# Check summary at end of log
tail -30 /tmp/install-test.log

# Check symlinks created
ls -la ~/ | grep -- '->'
ls -la ~/.config/ | grep -- '->'

# Check binaries available
command -v git
command -v nvim
command -v starship
```

**Step 5: Test shell functionality**

```bash
# Source new shell config
source ~/.bashrc  # or ~/.zshrc

# Test starship prompt
starship --version

# Test git
git --version

# Test nvim
nvim --version
```

**Step 6: Document test results**

```bash
cat > /tmp/test-results.md << 'EOF'
# Installation Test Results

**System:** $(uname -s -r)
**Package Manager:** $(command -v pacman || command -v apt || command -v dnf || command -v brew)
**Date:** $(date)

## Modules Discovered
$(./install.sh 2>&1 | grep "Discovered.*modules")

## Installation Summary
$(tail -20 /tmp/install-test.log)

## Verification
- [ ] Modules stowed successfully
- [ ] Dependencies installed
- [ ] Binaries available in PATH
- [ ] Shell configuration loaded
- [ ] No errors in installation

EOF
cat /tmp/test-results.md
```

---

### Task 13: Create Verification Script

**Files:**
- Create: `scripts/verify-install.sh`

**Step 1: Create verification script**

```bash
cat > scripts/verify-install.sh << 'EOF'
#!/usr/bin/env bash
# verify-install.sh - Verify dotfiles installation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"

echo "=== Dotfiles Installation Verification ==="
echo

# Check config.yaml structure
echo "1. Checking config.yaml structure..."
if yq -e '.modules' config.yaml >/dev/null 2>&1; then
    echo "  ❌ FAIL: config.yaml still has modules[] section (should be removed)"
    exit 1
else
    echo "  ✓ PASS: config.yaml has no modules[] section"
fi

if yq -e '.toolkits' config.yaml >/dev/null 2>&1; then
    echo "  ✓ PASS: config.yaml has toolkits section"
else
    echo "  ❌ FAIL: config.yaml missing toolkits section"
    exit 1
fi

if yq -e '.machines' config.yaml >/dev/null 2>&1; then
    echo "  ✓ PASS: config.yaml has machines section"
else
    echo "  ❌ FAIL: config.yaml missing machines section"
    exit 1
fi

# Check module discovery
echo
echo "2. Checking module discovery..."
module_count=0
for dir in */; do
    if [[ -f "$dir/deps.yaml" ]]; then
        ((module_count++))
    fi
done

if [[ $module_count -eq 0 ]]; then
    echo "  ❌ FAIL: No modules discovered (no deps.yaml files found)"
    exit 1
else
    echo "  ✓ PASS: Discovered $module_count modules"
fi

# Check deps.yaml format
echo
echo "3. Checking deps.yaml format..."
error_count=0
for dir in */; do
    if [[ ! -f "$dir/deps.yaml" ]]; then
        continue
    fi

    module_name=$(basename "$dir")

    # Check for top-level script section (should be removed)
    if yq -e '.script' "$dir/deps.yaml" >/dev/null 2>&1; then
        echo "  ❌ FAIL: $module_name still has top-level script section"
        ((error_count++))
    fi

    # Check for provides field (recommended but not required)
    if ! yq -e '.provides' "$dir/deps.yaml" >/dev/null 2>&1; then
        echo "  ⚠ WARN: $module_name missing provides field (recommended)"
    fi
done

if [[ $error_count -eq 0 ]]; then
    echo "  ✓ PASS: All deps.yaml files use new format"
else
    echo "  ❌ FAIL: $error_count modules have format errors"
    exit 1
fi

# Check for backup files
echo
echo "4. Checking for backup files..."
if [[ -f "install.sh.backup" && -f "config.yaml.backup" ]]; then
    echo "  ✓ PASS: Backup files exist"
else
    echo "  ⚠ WARN: Backup files missing (install.sh.backup, config.yaml.backup)"
fi

echo
echo "=== All Checks Passed ==="
echo
echo "System is ready. Run ./install.sh to install dotfiles."
EOF

chmod +x scripts/verify-install.sh
```

**Step 2: Run verification**

```bash
./scripts/verify-install.sh
```

Expected: All checks pass

**Step 3: Commit verification script**

```bash
git add scripts/verify-install.sh
git commit -m "feat: add installation verification script

Checks:
- config.yaml structure (no modules[], has toolkits/machines)
- Module discovery (finds deps.yaml files)
- deps.yaml format (no top-level script:, has provides)
- Backup files exist

Usage: ./scripts/verify-install.sh
"
```

---

## Phase 5: Documentation and Cleanup

### Task 14: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Update README with new architecture**

Update the README to reflect:
- Modules are auto-discovered
- No modules[] section in config.yaml
- deps.yaml uses prefix format
- Prerequisites auto-installed when possible

```bash
# Update relevant sections in README.md
# Focus on:
# - Quick start section
# - Configuration section
# - Module creation section
```

**Step 2: Commit README updates**

```bash
git add README.md
git commit -m "docs: update README for self-sufficient modules architecture"
```

---

### Task 15: Remove Migration Scripts

**Files:**
- Remove: `scripts/migrate-deps-yaml.sh` (no longer needed)
- Remove: `install.sh.backup` (keep in git history)
- Remove: `config.yaml.backup` (keep in git history)

**Step 1: Remove temporary migration scripts**

```bash
rm scripts/migrate-deps-yaml.sh
```

**Step 2: Remove backup files**

```bash
rm install.sh.backup config.yaml.backup
```

**Step 3: Commit cleanup**

```bash
git add -A
git commit -m "chore: remove migration scripts and backup files

Migration complete. Backup files preserved in git history if needed.
"
```

---

### Task 16: Create Release Commit

**Files:**
- Tag: Release version

**Step 1: Create final commit**

```bash
git add -A
git commit -m "feat: complete self-sufficient modules redesign

Major architecture changes:
- Modules auto-discovered from directories with deps.yaml
- config.yaml simplified (removed modules[] section)
- deps.yaml uses prefix format (aur:, cargo:, pip:)
- Prerequisites auto-installed (cargo, paru)
- Platform-specific scripts inline with package lists

Benefits:
- Single source of truth per module
- Easier to add new modules (just create directory + deps.yaml)
- No config.yaml synchronization issues
- Clearer prerequisite handling

Breaking changes:
- config.yaml format changed (modules[] removed)
- deps.yaml format changed (prefixes required, scripts inline)
- Module names must match directory names (no override)

Migration: See docs/plans/2026-02-24-self-sufficient-modules-design.md

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
"
```

**Step 2: Tag release**

```bash
git tag -a v2.0.0 -m "Self-sufficient modules architecture

Major redesign for simplicity and maintainability.
See CHANGELOG.md for full details.
"
```

**Step 3: Verify git history**

```bash
git log --oneline --graph -10
git show HEAD
```

Expected: Clean commit history with descriptive messages

---

## Phase 6: Multi-Platform Testing

### Task 17: Test on Arch Linux

**Files:**
- Test: Full installation on Arch system

**Step 1: Set up test environment**

If available, use:
- Physical Arch machine
- Arch VM
- Arch Docker container

```bash
# Docker option
docker run -it --rm archlinux:latest bash

# Inside container
pacman -Sy git base-devel
git clone <dotfiles-repo> /dotfiles
cd /dotfiles
```

**Step 2: Run installation**

```bash
./install.sh
```

**Step 3: Verify Arch-specific features**

```bash
# Check paru installed
command -v paru

# Check AUR packages
paru -Q | grep <aur-package-from-deps>

# Check native packages
pacman -Q git neovim starship
```

**Step 4: Document results**

Create `docs/testing/arch-test-results.md` with:
- System info
- Installation log
- Verification results
- Issues encountered

---

### Task 18: Test on Debian/Ubuntu

**Files:**
- Test: Full installation on Debian system

**Step 1: Set up test environment**

```bash
# Docker option
docker run -it --rm debian:latest bash

# Inside container
apt-get update
apt-get install -y git curl
git clone <dotfiles-repo> /dotfiles
cd /dotfiles
```

**Step 2: Run installation**

```bash
./install.sh
```

**Step 3: Verify Debian-specific features**

```bash
# Check install scripts ran
command -v starship  # Should exist if installed via script

# Check cargo packages
cargo install --list

# Check pip packages
pip list --user
```

**Step 4: Document results**

Create `docs/testing/debian-test-results.md`

---

### Task 19: Test on macOS (if available)

**Files:**
- Test: Full installation on macOS

**Step 1: Run on macOS system**

```bash
./install.sh
```

**Step 2: Verify Homebrew integration**

```bash
# Check brew packages
brew list

# Check binaries
command -v git starship nvim
```

**Step 3: Document results**

Create `docs/testing/macos-test-results.md`

---

## Phase 7: Finalization

### Task 20: Review and Polish

**Files:**
- Review: All changed files

**Step 1: Code review checklist**

- [ ] All functions have clear comments
- [ ] Error messages are helpful
- [ ] No dead code remaining
- [ ] Consistent coding style
- [ ] No hardcoded paths (use variables)

**Step 2: Test edge cases**

- Empty deps.yaml (packages: {})
- Module with only provides field
- Module with scripts but no packages
- Hostname not in config.yaml

**Step 3: Final verification**

```bash
./scripts/verify-install.sh
bash -n install.sh
DRY_RUN=true ./install.sh
```

**Step 4: Update CHANGELOG**

Document all changes in CHANGELOG.md

**Step 5: Final commit**

```bash
git add -A
git commit -m "chore: final polish and verification

All tests passing on Arch, Debian, and macOS.
Edge cases handled.
Documentation complete.
"
```

---

## Success Criteria

Installation is successful when:

1. ✅ `./scripts/verify-install.sh` passes all checks
2. ✅ `DRY_RUN=true ./install.sh` completes without errors
3. ✅ Real installation completes successfully on current system
4. ✅ Modules are discovered automatically (no manual registration)
5. ✅ Dependencies install correctly (native, AUR, cargo, pip, scripts)
6. ✅ Verification checks pass (binaries available in PATH)
7. ✅ Symlinks created correctly (stow successful)
8. ✅ No errors in installation summary
9. ✅ Tests pass on at least 2 different platforms (Arch + Debian or macOS)
10. ✅ Documentation updated and accurate

---

## Rollback Plan

If major issues encountered:

```bash
# Restore backups
cp install.sh.backup install.sh
cp config.yaml.backup config.yaml

# Revert all changes
git reset --hard <commit-before-changes>

# Or revert specific commits
git revert <commit-hash>
```

---

## Notes

- Each task builds on previous tasks - complete in order
- Test thoroughly after each phase before proceeding
- Keep commits small and descriptive
- Run `bash -n install.sh` after each modification to catch syntax errors
- Use `DRY_RUN=true ./install.sh` to test without actual installation
