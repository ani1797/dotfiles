# config.yaml Specification

Complete reference for the `config.yaml` system configuration format.

## Overview

The `config.yaml` file is the central configuration that defines:
- **Toolkits:** Named groups of related modules
- **Machines:** Hostname-to-modules mappings that determine what gets installed

Modules themselves are NOT defined in this file - they are auto-discovered from directories containing `deps.yaml`.

## File Structure

```yaml
# Toolkit definitions - group related modules
toolkits:
  - name: <string>
    modules: <string[]>

# Machine profiles - hostname-to-modules mappings
machines:
  - hostname: <string | pattern>
    modules: <module-reference[]>
```

## Field Reference

### `toolkits` (Optional)

**Type:** Array of toolkit objects

**Description:** Named groups of modules for easier machine configuration. Toolkits are expanded at install time to their constituent modules.

**Purpose:**
- Reduce repetition in machine profiles
- Provide semantic grouping (e.g., "python-dev", "wayland-desktop")
- Make machine configs easier to understand

---

#### Toolkit Object

**Fields:**
- `name` (required): Unique identifier for the toolkit
- `modules` (required): Array of module names

**Examples:**

```yaml
toolkits:
  # Terminal shells and prompt
  - name: "terminal"
    modules: ["bash", "fish", "zsh", "starship"]

  # Development tools
  - name: "dev-tools"
    modules: ["git", "tmux", "direnv"]

  # Python ecosystem
  - name: "python-dev"
    modules: ["pip", "uv"]

  # Complete desktop environment
  - name: "wayland-desktop"
    modules: ["hyprland", "waybar", "swaync", "sddm", "rofi", "kitty", "theme", "fonts"]
```

**Validation:**
- Toolkit names must be unique
- Module names in toolkits are validated against discovered modules at runtime
- Missing modules generate warnings but don't fail installation
- Toolkits cannot reference other toolkits (flat structure only)

**Best Practices:**
- Use descriptive names ("python-dev" not "pd")
- Group by function or domain ("cloud-native", "editors")
- Keep toolkits focused (3-8 modules typically)

---

### `machines` (Required)

**Type:** Array of machine objects

**Description:** Maps hostnames to module lists. Determines what gets installed on each system.

---

#### Machine Object

**Fields:**
- `hostname` (required): Hostname or pattern to match
- `modules` (required): Array of module references

---

##### `hostname` Field

**Type:** String (literal or glob pattern)

**Description:** The hostname to match against the system's hostname.

**Matching:**
- **Exact match:** `"HOME-DESKTOP"` matches only that exact hostname
- **Case-insensitive:** `"home-desktop"` matches `"HOME-DESKTOP"`
- **Glob patterns:** `"codespaces-*"` matches any hostname starting with "codespaces-"

**Pattern Syntax:**
- `*` - matches any sequence of characters
- `?` - matches any single character
- Patterns are case-insensitive

**Examples:**

```yaml
machines:
  # Exact hostname
  - hostname: "HOME-DESKTOP"
    modules: [...]

  # Glob pattern for multiple systems
  - hostname: "codespaces-*"
    modules: [...]

  # Another pattern
  - hostname: "server-??-prod"  # Matches server-01-prod, server-02-prod, etc.
    modules: [...]
```

**Behavior:**
- Installer uses the **first matching** machine profile
- If no match found, installation fails with error
- Get current hostname: `hostname` command

**Best Practices:**
- Use exact hostnames for personal machines
- Use patterns for dynamic environments (Codespaces, VMs, cloud instances)
- Put more specific patterns before generic ones

---

##### `modules` Field

**Type:** Array of module references

**Description:** List of modules or toolkits to install on this machine.

**Module Reference Types:**

###### 1. Toolkit Reference (String)

**Format:** `"toolkit-name"`

**Description:** References a toolkit defined in the `toolkits` section. Expands to all modules in that toolkit.

**Example:**

```yaml
toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "zsh", "starship"]

machines:
  - hostname: "laptop"
    modules:
      - "terminal"  # Expands to: bash, fish, zsh, starship
```

---

###### 2. Direct Module Reference (String)

**Format:** `"module-name"`

**Description:** References a single module directly by name.

**Example:**

```yaml
machines:
  - hostname: "laptop"
    modules:
      - "git"       # Direct module reference
      - "nvim"      # Direct module reference
      - "tmux"      # Direct module reference
```

---

###### 3. Module with Target Override (Object)

**Format:**
```yaml
name: "module-name"
target: "target-directory"
```

**Description:** References a module and overrides its stow target directory.

**Fields:**
- `name` (required): Module name
- `target` (required): Target directory for stowing (supports environment variables)

**Examples:**

```yaml
machines:
  - hostname: "laptop"
    modules:
      - "git"  # Uses default target ($HOME)

      # Override target for specific module
      - name: "wayvnc"
        target: "$HOME/.config"

      # System-level configuration
      - name: "sddm"
        target: "/etc/sddm"
```

**Environment Variables:**
- `$HOME` - User's home directory
- `$USER` - Username
- `$XDG_CONFIG_HOME` - XDG config directory (defaults to `$HOME/.config`)

**Best Practices:**
- Default target is `$HOME` - only override when necessary
- Use `$HOME/.config` for config-only modules
- System targets (like `/etc`) require sudo

---

## Complete Examples

### Minimal Configuration

```yaml
toolkits:
  - name: "essentials"
    modules: ["git", "nvim", "tmux"]

machines:
  - hostname: "my-laptop"
    modules:
      - "essentials"
```

---

### Multiple Machines with Toolkits

```yaml
toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "zsh", "starship"]
  - name: "editors"
    modules: ["nvim"]
  - name: "dev-tools"
    modules: ["git", "tmux", "direnv"]
  - name: "python-dev"
    modules: ["pip", "uv"]

machines:
  # Personal workstation
  - hostname: "HOME-DESKTOP"
    modules:
      - "terminal"
      - "editors"
      - "dev-tools"
      - "python-dev"

  # Work laptop
  - hostname: "work-laptop"
    modules:
      - "terminal"
      - "editors"
      - "dev-tools"

  # Remote servers (pattern match)
  - hostname: "server-*"
    modules:
      - "bash"      # Just bash, no other shells
      - "git"       # Just git
      - "nvim"      # Just editor
```

---

### Advanced Configuration with Target Overrides

```yaml
toolkits:
  - name: "wayland-desktop"
    modules: ["hyprland", "waybar", "swaync", "sddm", "rofi", "kitty", "theme", "fonts"]
  - name: "workstation-base"
    modules: ["bash", "fish", "zsh", "starship", "git", "tmux", "direnv", "nvim"]

machines:
  - hostname: "HOME-DESKTOP"
    modules:
      - "wayland-desktop"
      - "workstation-base"

      # System-level display manager config
      - name: "sddm"
        target: "/etc/sddm"

      # VNC server in .config
      - name: "wayvnc"
        target: "$HOME/.config"

      # Regular modules
      - "python-dev"
      - "npm"
```

---

### Dynamic Environments (Codespaces, VMs)

```yaml
toolkits:
  - name: "minimal-server"
    modules: ["bash", "starship", "git", "ssh", "direnv"]
  - name: "dev-full"
    modules: ["nvim", "tmux", "python-dev", "npm"]

machines:
  # GitHub Codespaces (any codespace)
  - hostname: "codespaces-*"
    modules:
      - "minimal-server"
      - "zsh"           # Add zsh
      - "dev-full"      # Full dev tools

  # Arch Linux test VMs
  - hostname: "arch-*"
    modules:
      - "minimal-server"
      - "dev-full"

  # Any temporary VM
  - hostname: "temp-*"
    modules:
      - "minimal-server"  # Just basics
```

---

## Validation Rules

### Required Sections
- ✅ `machines` array must exist and have at least one entry
- ✅ Each machine must have `hostname` and `modules`

### Optional Sections
- ✅ `toolkits` array is optional (can have zero toolkits)

### Toolkit Validation
- ✅ Toolkit names must be unique
- ✅ Module names in toolkits validated at runtime against discovered modules
- ⚠️ Missing modules generate warnings
- ❌ Toolkits cannot reference other toolkits (no nesting)

### Machine Validation
- ✅ Hostnames don't need to be unique (first match wins)
- ✅ Glob patterns are supported in hostnames
- ⚠️ Duplicate module references (via multiple toolkits) are deduplicated
- ⚠️ Missing module/toolkit references generate warnings

### Module Reference Validation
- ✅ String references can be toolkit names or module names
- ✅ Object references must have `name` and `target`
- ✅ Target supports environment variables
- ⚠️ Invalid module/toolkit names generate warnings (but don't fail)

---

## Common Mistakes

### Referencing Non-Existent Modules

```yaml
# ❌ Wrong - module doesn't exist
toolkits:
  - name: "editors"
    modules: ["vim", "emacs"]  # But no vim/ or emacs/ directory

# ✅ Correct - only reference existing modules
toolkits:
  - name: "editors"
    modules: ["nvim"]  # nvim/ directory exists
```

**Behavior:** Installer warns but continues with available modules.

---

### Circular References

```yaml
# ❌ Wrong - toolkit references another toolkit
toolkits:
  - name: "base"
    modules: ["git", "nvim"]
  - name: "extended"
    modules: ["base", "tmux"]  # Can't reference toolkit "base"

# ✅ Correct - duplicate module names
toolkits:
  - name: "base"
    modules: ["git", "nvim"]
  - name: "extended"
    modules: ["git", "nvim", "tmux"]  # List all modules
```

**Behavior:** Installer treats "base" as a module name, warns if not found.

---

### Duplicate Module References

```yaml
# ⚠️ Warning - bash referenced twice
toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "zsh"]

machines:
  - hostname: "laptop"
    modules:
      - "terminal"  # Includes bash
      - "bash"      # Duplicate reference

# ✅ Better - avoid explicit duplicates
machines:
  - hostname: "laptop"
    modules:
      - "terminal"  # Bash already included
```

**Behavior:** Installer deduplicates and installs only once, but warns.

---

### Missing Target Directory

```yaml
# ❌ Wrong - target omitted in object form
machines:
  - hostname: "laptop"
    modules:
      - name: "sddm"  # Missing target field

# ✅ Correct - include target
machines:
  - hostname: "laptop"
    modules:
      - name: "sddm"
        target: "/etc/sddm"
```

---

### Non-Matching Hostname

```yaml
machines:
  - hostname: "desktop"
    modules: [...]

# Current hostname: laptop
# Result: "No modules found for hostname 'laptop'"
```

**Solution:** Add a machine profile for the current hostname or use a pattern.

---

## Module Resolution Order

When a machine profile contains multiple module references, they are resolved in this order:

1. **Expand toolkits** - Replace toolkit names with their module lists
2. **Deduplicate** - Remove duplicate module references (first occurrence wins)
3. **Validate** - Check that all modules exist (warn if missing)
4. **Apply target overrides** - Store target overrides for modules specified as objects

**Example:**

```yaml
toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "starship"]
  - name: "dev-tools"
    modules: ["git", "bash", "tmux"]  # bash duplicated

machines:
  - hostname: "laptop"
    modules:
      - "terminal"     # Expands to: bash, fish, starship
      - "dev-tools"    # Expands to: git, bash, tmux (bash already seen, deduplicated)
      - "nvim"         # Direct reference
```

**Resolution:**
1. Expand "terminal" → `[bash, fish, starship]`
2. Expand "dev-tools" → `[git, bash, tmux]` (bash already in list, skip)
3. Add "nvim" → `[bash, fish, starship, git, tmux, nvim]`

**Final module list:** `bash`, `fish`, `starship`, `git`, `tmux`, `nvim`

---

## Best Practices

### Toolkit Design

1. **Keep toolkits focused** - Group by function, not size
   ```yaml
   # ✅ Good - focused by function
   - name: "python-dev"
     modules: ["pip", "uv"]

   # ❌ Bad - too generic
   - name: "misc"
     modules: ["git", "nvim", "tmux", "docker", "kubectl"]
   ```

2. **Use semantic names** - Describe what the toolkit provides
   ```yaml
   # ✅ Good - clear purpose
   - name: "cloud-native"
     modules: ["k8s", "terraform", "podman"]

   # ❌ Bad - unclear
   - name: "stuff"
     modules: ["k8s", "terraform", "podman"]
   ```

3. **Avoid deep dependencies** - Don't make modules depend on each other
   ```yaml
   # ✅ Good - independent modules
   - name: "editors"
     modules: ["nvim"]
   - name: "terminal"
     modules: ["bash", "zsh", "starship"]

   # ❌ Bad - nvim config assumes starship installed
   # (Document recommendations in module README instead)
   ```

### Machine Profiles

1. **Prefer patterns for dynamic environments**
   ```yaml
   # ✅ Good - matches all codespaces
   - hostname: "codespaces-*"
     modules: [...]

   # ❌ Bad - hardcoded codespace name
   - hostname: "codespaces-opulent-space-guacamole-q9j6j9j"
     modules: [...]
   ```

2. **Order patterns from specific to general**
   ```yaml
   # ✅ Good - specific patterns first
   machines:
     - hostname: "my-special-laptop"  # Exact match
       modules: ["full-desktop"]
     - hostname: "laptop-*"           # General pattern
       modules: ["minimal"]
     - hostname: "*"                  # Catch-all
       modules: ["essentials"]

   # ❌ Bad - general pattern first (hides specific)
   machines:
     - hostname: "*"                  # Matches everything!
       modules: ["essentials"]
     - hostname: "my-special-laptop"  # Never reached
       modules: ["full-desktop"]
   ```

3. **Use toolkits for shared configurations**
   ```yaml
   # ✅ Good - reuse toolkits
   machines:
     - hostname: "HOME-DESKTOP"
       modules: ["workstation-base", "wayland-desktop"]
     - hostname: "work-laptop"
       modules: ["workstation-base", "minimal-desktop"]

   # ❌ Bad - duplicate lists
   machines:
     - hostname: "HOME-DESKTOP"
       modules: ["bash", "fish", "git", "nvim", "tmux", "hyprland", ...]
     - hostname: "work-laptop"
       modules: ["bash", "fish", "git", "nvim", "tmux", ...]
   ```

### Target Overrides

1. **Only override when necessary** - Default target is `$HOME`
2. **Use environment variables** - Don't hardcode paths
   ```yaml
   # ✅ Good - portable
   - name: "wayvnc"
     target: "$HOME/.config"

   # ❌ Bad - hardcoded username
   - name: "wayvnc"
     target: "/home/anirudh/.config"
   ```

3. **Document system-level configs** - Targets like `/etc` need sudo
   ```yaml
   # System display manager config (requires sudo)
   - name: "sddm"
     target: "/etc/sddm"
   ```

---

## Migration from Old Format

The old format included a `modules:[]` section defining all modules:

**Old Format:**
```yaml
modules:
  - name: "git"
    path: "git"
  - name: "nvim"
    path: "nvim"
  - name: "tmux"
    path: "tmux"

toolkits:
  - name: "dev-tools"
    modules: ["git", "nvim", "tmux"]

machines:
  - hostname: "laptop"
    modules: ["dev-tools"]
```

**New Format:**
```yaml
# No modules:[] section - auto-discovered!

toolkits:
  - name: "dev-tools"
    modules: ["git", "nvim", "tmux"]

machines:
  - hostname: "laptop"
    modules: ["dev-tools"]
```

**Migration:**
1. Remove entire `modules:[]` section
2. Keep `toolkits` and `machines` as-is
3. Module names now match directory names (no override)

---

## Related Documentation

- [deps.yaml Specification](deps-yaml-spec.md) - Module dependency format
- [Module Creation Guide](module-creation.md) - How to create modules
- [Installation Guide](installation.md) - Installing dotfiles on a new system
- [Architecture Overview](architecture.md) - How the system works
