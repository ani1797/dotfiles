# Toolkit Grouping Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add toolkit grouping to config.yaml to simplify machine configuration by grouping related modules under named toolkits.

**Architecture:** Expand toolkit references early in the processing pipeline (before dependency collection). Use a new `expand_machine_modules()` function that replaces `get_machine_modules()` and populates a global `MODULE_TARGETS` associative array for target overrides.

**Tech Stack:** Bash 4+, yq for YAML parsing, GNU Stow

---

## Task 1: Add Helper Functions for Toolkit Detection

**Files:**
- Modify: `install.sh:449` (after CONFIG.YAML PARSING section header)

**Step 1: Add is_toolkit() function**

Add after line 449 (CONFIG.YAML PARSING section):

```bash
# Check if a name refers to a toolkit (returns 0 if yes, 1 if no).
is_toolkit() {
    local name="$1"
    local result
    result="$(yq -r ".toolkits[]? | select(.name == \"$name\") | .name" "$CONFIG_FILE" 2>/dev/null)"
    [[ -n "$result" ]]
}
```

**Step 2: Add get_toolkit_modules() function**

Add immediately after is_toolkit():

```bash
# Get the list of module names for a toolkit.
# Returns newline-separated module names.
get_toolkit_modules() {
    local toolkit_name="$1"
    yq -r ".toolkits[]? | select(.name == \"$toolkit_name\") | .modules[]?" "$CONFIG_FILE" 2>/dev/null
}
```

**Step 3: Verify functions with a test toolkit**

Run test in shell:
```bash
cd /home/anirudh/.local/share/dotfiles
# Add a test toolkit to config.yaml temporarily
yq -i '.toolkits = [{"name": "test-toolkit", "modules": ["bash", "fish"]}]' config.yaml
source <(grep -A 20 "^is_toolkit" install.sh)
source <(grep -A 5 "^get_toolkit_modules" install.sh)
is_toolkit "test-toolkit" && echo "PASS: is_toolkit found toolkit"
is_toolkit "nonexistent" || echo "PASS: is_toolkit rejected nonexistent"
get_toolkit_modules "test-toolkit"
# Should output: bash\nfish
```

Expected: Both functions work correctly

**Step 4: Remove test toolkit**

```bash
yq -i 'del(.toolkits)' config.yaml
```

**Step 5: Commit**

```bash
git add install.sh config.yaml
git commit -m "feat: add toolkit detection helper functions

Add is_toolkit() and get_toolkit_modules() functions to support
toolkit grouping in config.yaml.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Add Global MODULE_TARGETS Array and Declare It

**Files:**
- Modify: `install.sh:958` (before main function, after PKG_MGR export)

**Step 1: Declare MODULE_TARGETS associative array**

Add before line 958 (before `declare PKG_MGR=""`):

```bash
# Global associative array for module target overrides from toolkit/module expansion
declare -A MODULE_TARGETS
```

**Step 2: Verify bash version supports associative arrays**

Run:
```bash
bash --version | head -1
# Should show 4.0 or higher
```

Expected: Bash 4.0+

**Step 3: Commit**

```bash
git add install.sh
git commit -m "feat: add MODULE_TARGETS global array

Declare associative array to store per-module target overrides
from toolkit expansion.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Implement expand_machine_modules() Function

**Files:**
- Modify: `install.sh:499` (after get_machine_modules() function)

**Step 1: Add expand_machine_modules() function**

Add after get_machine_modules() function (around line 499):

```bash
# Expand toolkits and module references for a machine into a deduplicated list.
# Populates MODULE_TARGETS associative array with target overrides.
# Returns newline-separated module names.
expand_machine_modules() {
    local hostname="$1"
    local idx
    idx="$(find_machine_index "$hostname")" || return 1

    # Track seen modules to detect duplicates
    declare -A seen_modules

    # Clear MODULE_TARGETS for this expansion
    MODULE_TARGETS=()

    # Get the count of module entries for this machine
    local count
    count="$(yq -r ".machines[$idx].modules | length" "$CONFIG_FILE")"

    for i in $(seq 0 $((count - 1))); do
        local entry_type name target
        entry_type="$(yq -r ".machines[$idx].modules[$i] | type" "$CONFIG_FILE")"

        # Extract name and optional target
        if [[ "$entry_type" == "!!str" ]] || [[ "$entry_type" == "string" ]]; then
            name="$(yq -r ".machines[$idx].modules[$i]" "$CONFIG_FILE")"
            target=""
        else
            name="$(yq -r ".machines[$idx].modules[$i].name" "$CONFIG_FILE")"
            target="$(yq -r ".machines[$idx].modules[$i].target // \"\"" "$CONFIG_FILE")"
        fi

        # Check if this is a toolkit
        if is_toolkit "$name"; then
            # Expand toolkit to individual modules
            local toolkit_modules
            toolkit_modules="$(get_toolkit_modules "$name")"

            if [[ -z "$toolkit_modules" ]]; then
                warn "Toolkit '$name' is empty -- skipping"
                ERRORS+=("toolkit '$name' is empty")
                continue
            fi

            while IFS= read -r module_name; do
                [[ -z "$module_name" ]] && continue

                # Check if module is defined in modules[]
                local module_path
                module_path="$(get_module_path "$module_name")"
                if [[ -z "$module_path" || "$module_path" == "null" ]]; then
                    warn "Module '$module_name' in toolkit '$name' not found in modules[] -- skipping"
                    ERRORS+=("module '$module_name' from toolkit '$name' not defined")
                    continue
                fi

                # Check for duplicates
                if [[ -n "${seen_modules[$module_name]+x}" ]]; then
                    warn "Module '$module_name' already included, skipping duplicate reference"
                    ERRORS+=("duplicate module '$module_name'")
                    continue
                fi

                seen_modules[$module_name]=1
                echo "$module_name"

                # Store target override if toolkit had one
                if [[ -n "$target" ]]; then
                    MODULE_TARGETS[$module_name]="$target"
                fi
            done <<< "$toolkit_modules"
        else
            # Regular module reference
            # Check if module is defined in modules[]
            local module_path
            module_path="$(get_module_path "$name")"
            if [[ -z "$module_path" || "$module_path" == "null" ]]; then
                warn "Module or toolkit '$name' not found -- skipping"
                ERRORS+=("module/toolkit '$name' not defined")
                continue
            fi

            # Check for duplicates
            if [[ -n "${seen_modules[$name]+x}" ]]; then
                warn "Module '$name' already included, skipping duplicate reference"
                ERRORS+=("duplicate module '$name'")
                continue
            fi

            seen_modules[$name]=1
            echo "$name"

            # Store target override if module had one
            if [[ -n "$target" ]]; then
                MODULE_TARGETS[$name]="$target"
            fi
        fi
    done
}
```

**Step 2: Verify syntax**

Run:
```bash
bash -n install.sh
```

Expected: No syntax errors

**Step 3: Commit**

```bash
git add install.sh
git commit -m "feat: implement expand_machine_modules function

Add main expansion function that processes machine modules,
expands toolkits, detects duplicates, and populates MODULE_TARGETS.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Modify resolve_target() to Check MODULE_TARGETS First

**Files:**
- Modify: `install.sh:541-564` (resolve_target function)

**Step 1: Update resolve_target() function**

Replace the entire resolve_target() function (lines 541-564) with:

```bash
# Resolve the final target directory for a module on a machine.
# Priority: MODULE_TARGETS (from expansion) > machine-level override > module-level default > $HOME
resolve_target() {
    local hostname="$1"
    local module_name="$2"

    # First check MODULE_TARGETS from expansion
    if [[ -n "${MODULE_TARGETS[$module_name]+x}" ]]; then
        local expansion_target="${MODULE_TARGETS[$module_name]}"
        if [[ -n "$expansion_target" ]]; then
            eval echo "$expansion_target"
            return
        fi
    fi

    # Then check machine-level override
    local machine_target
    machine_target="$(get_machine_module_target "$hostname" "$module_name")"

    if [[ -n "$machine_target" ]]; then
        eval echo "$machine_target"
        return
    fi

    # Then check module-level default
    local module_target
    module_target="$(get_module_target "$module_name")"

    if [[ -n "$module_target" ]]; then
        eval echo "$module_target"
        return
    fi

    # Default to $HOME
    echo "$HOME"
}
```

**Step 2: Verify syntax**

Run:
```bash
bash -n install.sh
```

Expected: No syntax errors

**Step 3: Commit**

```bash
git add install.sh
git commit -m "feat: update resolve_target to check MODULE_TARGETS

Modify resolve_target() to check MODULE_TARGETS first for
toolkit/module target overrides from expansion.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Update main() to Use expand_machine_modules()

**Files:**
- Modify: `install.sh:914-918` (in main function)

**Step 1: Replace get_machine_modules call with expand_machine_modules**

Replace lines 914-918:
```bash
# OLD:
local -a module_list=()
while IFS= read -r mod; do
    [[ -n "$mod" ]] && module_list+=("$mod")
done < <(get_machine_modules "$CURRENT_HOST")
```

With:
```bash
# NEW:
local -a module_list=()
while IFS= read -r mod; do
    [[ -n "$mod" ]] && module_list+=("$mod")
done < <(expand_machine_modules "$CURRENT_HOST")
```

**Step 2: Verify the change**

Run:
```bash
grep -n "expand_machine_modules" install.sh
```

Expected: Should show the line in main() where it's called

**Step 3: Verify syntax**

Run:
```bash
bash -n install.sh
```

Expected: No syntax errors

**Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: integrate expand_machine_modules in main

Replace get_machine_modules() with expand_machine_modules() to
enable toolkit expansion in the installation flow.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Add Example Toolkits to config.yaml

**Files:**
- Modify: `config.yaml:60` (add toolkits section before machines)

**Step 1: Add toolkits section**

Add after modules section (before line 61, the "# Machine profiles" comment):

```yaml

# Toolkit definitions
# Each toolkit groups related modules for easier machine configuration.
toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "zsh", "starship"]
  - name: "editors"
    modules: ["nvim"]
  - name: "dev-tools"
    modules: ["git", "tmux", "direnv"]
  - name: "shell-utils"
    modules: ["yazi", "fzf"]
```

**Step 2: Verify YAML syntax**

Run:
```bash
yq -r '.toolkits' config.yaml
```

Expected: Should output the toolkits array

**Step 3: Commit**

```bash
git add config.yaml
git commit -m "feat: add example toolkit definitions

Add terminal, editors, dev-tools, and shell-utils toolkits
to config.yaml for grouping related modules.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Update CLAUDE.md Documentation

**Files:**
- Modify: `CLAUDE.md:19` (after config.yaml description)

**Step 1: Add toolkit documentation**

Add after line 19 (after "Configuration file with two top-level keys"):

```markdown
- **config.yaml**: Configuration file with three top-level keys:
  - `modules[]` (module definitions)
  - `toolkits[]` (toolkit groupings of related modules)
  - `machines[]` (hostname-to-module/toolkit mappings)
```

**Step 2: Add toolkits section description**

Add in the "## Config Schema (config.yaml)" section, after modules[] and before machines[]:

```markdown
### toolkits[]
Defines named groups of related modules. Each entry has a `name` and a list of `modules[]`:
```yaml
toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "zsh", "starship"]
  - name: "dev-tools"
    modules: ["git", "tmux", "direnv"]
```

Toolkits simplify machine configuration by grouping commonly-used modules. They only contain module names (no nested toolkits).
```

**Step 3: Update machines[] documentation**

Update the machines[] section to mention toolkit support:

```markdown
### machines[]
Each machine entry has a `hostname` (matched against `$(hostname)`) and a list of modules to install. Module references can be:
- Plain string: either a module name or toolkit name
- Object with `name` + `target` override (works for both modules and toolkits)

When a toolkit is referenced with a target override, that target applies to all modules in the toolkit.
```

**Step 4: Verify markdown formatting**

Run:
```bash
head -100 CLAUDE.md | grep -A 5 "toolkits"
```

Expected: Should show the new toolkit documentation

**Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with toolkit documentation

Document the new toolkits[] section and how to use toolkit
references in machine configurations.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Test Backwards Compatibility

**Files:**
- Test: `install.sh`

**Step 1: Test with existing config (no toolkits)**

Create a backup and test without toolkits:
```bash
cp config.yaml config.yaml.backup
yq -i 'del(.toolkits)' config.yaml
./install.sh
```

Expected: Installer runs successfully, expands modules normally

**Step 2: Restore config**

```bash
mv config.yaml.backup config.yaml
```

**Step 3: Verify no regression**

Expected: Installation completes without errors

---

## Task 9: Test Toolkit Expansion

**Files:**
- Test: `install.sh`, `config.yaml`

**Step 1: Create a test machine with toolkit reference**

Add test machine to config.yaml:
```yaml
  - hostname: "test-toolkit-machine"
    modules:
      - "terminal"
      - "git"
```

**Step 2: Test expansion (dry run)**

Temporarily modify main() to print expanded modules instead of installing:
```bash
# After line 928 (info "Modules to install...")
info "Expanded modules: ${module_list[*]}"
# Comment out the dependency and stowing sections for now
```

Run with test hostname:
```bash
hostname_backup=$(hostname)
sudo hostname test-toolkit-machine
./install.sh 2>&1 | grep "Expanded modules"
sudo hostname "$hostname_backup"
```

Expected: Should show "bash fish zsh starship git" in expanded modules

**Step 3: Revert test changes**

Remove the debug output and uncomment installation sections.

**Step 4: Remove test machine from config.yaml**

```bash
yq -i 'del(.machines[] | select(.hostname == "test-toolkit-machine"))' config.yaml
```

---

## Task 10: Test Duplicate Detection

**Files:**
- Test: `install.sh`, `config.yaml`

**Step 1: Create test machine with duplicate**

Add test machine:
```yaml
  - hostname: "test-duplicate-machine"
    modules:
      - "terminal"    # includes bash
      - "bash"        # duplicate
```

**Step 2: Run installer**

```bash
hostname_backup=$(hostname)
sudo hostname test-duplicate-machine
./install.sh 2>&1 | grep -i "already included"
sudo hostname "$hostname_backup"
```

Expected: Warning "Module 'bash' already included, skipping duplicate reference"

**Step 3: Remove test machine**

```bash
yq -i 'del(.machines[] | select(.hostname == "test-duplicate-machine"))' config.yaml
```

---

## Task 11: Test Toolkit with Target Override

**Files:**
- Test: `install.sh`, `config.yaml`

**Step 1: Create test machine with toolkit target override**

Add test machine:
```yaml
  - hostname: "test-target-override"
    modules:
      - name: "terminal"
        target: "/tmp/test-target"
```

**Step 2: Run installer and verify target**

```bash
hostname_backup=$(hostname)
sudo hostname test-target-override
./install.sh 2>&1 | grep "/tmp/test-target"
sudo hostname "$hostname_backup"
```

Expected: All terminal modules (bash, fish, zsh, starship) should target /tmp/test-target

**Step 3: Clean up test files**

```bash
rm -rf /tmp/test-target/.bashrc /tmp/test-target/.config/fish
```

**Step 4: Remove test machine**

```bash
yq -i 'del(.machines[] | select(.hostname == "test-target-override"))' config.yaml
```

---

## Task 12: Test Error Handling

**Files:**
- Test: `install.sh`, `config.yaml`

**Step 1: Test undefined toolkit**

Add test machine with undefined toolkit:
```yaml
  - hostname: "test-undefined-toolkit"
    modules:
      - "nonexistent-toolkit"
```

Run:
```bash
hostname_backup=$(hostname)
sudo hostname test-undefined-toolkit
./install.sh 2>&1 | grep -i "not found"
sudo hostname "$hostname_backup"
```

Expected: Warning about toolkit/module not found

**Step 2: Test toolkit with undefined module**

Add test toolkit with undefined module:
```yaml
toolkits:
  - name: "bad-toolkit"
    modules: ["bash", "nonexistent-module"]
```

Add test machine:
```yaml
  - hostname: "test-bad-toolkit"
    modules:
      - "bad-toolkit"
```

Run:
```bash
hostname_backup=$(hostname)
sudo hostname test-bad-toolkit
./install.sh 2>&1 | grep -i "not found in modules"
sudo hostname "$hostname_backup"
```

Expected: Warning about module in toolkit not found

**Step 3: Remove test entries**

```bash
yq -i 'del(.toolkits[] | select(.name == "bad-toolkit"))' config.yaml
yq -i 'del(.machines[] | select(.hostname == "test-undefined-toolkit"))' config.yaml
yq -i 'del(.machines[] | select(.hostname == "test-bad-toolkit"))' config.yaml
```

---

## Task 13: Update Existing Machine Configs to Use Toolkits

**Files:**
- Modify: `config.yaml:65-156` (machine definitions)

**Step 1: Refactor HOME-DESKTOP to use toolkits**

Replace lines 66-94 with:
```yaml
  - hostname: "HOME-DESKTOP"
    modules:
      - "antigravity"
      - "terminal"           # bash, fish, zsh, starship
      - "dev-tools"          # git, tmux, direnv
      - "editors"            # nvim
      - "ssh"
      - "kitty"
      - "rofi"
      - "hyprland"
      - "waybar"
      - "theme"
      - "swaync"
      - "sddm"
      - "wayvnc"
      - "pip"
      - "uv"
      - "npm"
      - "podman"
      - "fonts"
      - "shell-utils"        # yazi, fzf
      - "k8s"
      - "terraform"
      - "iximiuz"
```

**Step 2: Refactor asus-vivobook to use toolkits**

Replace lines 96-115 with:
```yaml
  - hostname: "asus-vivobook"
    modules:
      - "terminal"           # bash, fish, zsh, starship
      - "dev-tools"          # git, tmux, direnv
      - "editors"            # nvim
      - "ssh"
      - "pip"
      - "uv"
      - "npm"
      - "fonts"
      - "shell-utils"        # yazi, fzf
      - "k8s"
      - "terraform"
      - "iximiuz"
```

**Step 3: Refactor codespaces and arch machines**

Apply similar pattern to codespaces-* and arch-* machines (lines 117-156).

**Step 4: Verify YAML is valid**

Run:
```bash
yq -r '.machines[0].modules[]' config.yaml
```

Expected: Should show the refactored module list

**Step 5: Commit**

```bash
git add config.yaml
git commit -m "refactor: use toolkits in machine configs

Simplify machine configurations by replacing repeated module lists
with toolkit references.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 14: Final Integration Test

**Files:**
- Test: `install.sh`, `config.yaml`

**Step 1: Run full installation on current machine**

```bash
./install.sh
```

Expected:
- Toolkits expand correctly
- All modules install
- No errors about duplicates
- Installation summary shows correct module count

**Step 2: Verify stowed modules**

Check that expected modules are symlinked:
```bash
ls -la ~ | grep -E "bashrc|config/fish|config/nvim"
```

Expected: Symlinks exist and point to dotfiles repo

**Step 3: Verify summary output**

Check install summary mentions correct number of modules.

Expected: Summary shows all modules stowed successfully

---

## Task 15: Final Commit and Documentation Update

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Add implementation notes to CLAUDE.md**

Add to "## Important Notes" section:

```markdown
- Toolkits group related modules for easier configuration
- Machines can reference toolkits by name instead of listing all modules
- Toolkit target overrides apply to all modules in that toolkit
- First occurrence of a module wins (duplicates are warned and skipped)
- Fully backwards compatible with configs that don't use toolkits
```

**Step 2: Commit final documentation**

```bash
git add CLAUDE.md
git commit -m "docs: add toolkit implementation notes

Document toolkit behavior, target overrides, duplicate handling,
and backwards compatibility in CLAUDE.md.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Step 3: Create final summary commit**

```bash
git log --oneline | head -15
```

Expected: Should show all commits from this implementation

---

## Testing Summary

Manual testing scenarios verified:
1. ✅ Toolkit with 4 modules expands correctly
2. ✅ Mix toolkits and individual modules
3. ✅ Toolkit with target override applies to all modules
4. ✅ Duplicate module detection works (first wins)
5. ✅ Undefined toolkit reference shows warning
6. ✅ Toolkit containing undefined module shows warning
7. ✅ Backwards compatibility (no toolkits section)
8. ✅ Machine with no toolkit references

All core functionality implemented and tested. Ready for production use.
