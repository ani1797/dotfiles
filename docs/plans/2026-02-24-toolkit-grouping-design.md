# Toolkit Grouping Design

**Date:** 2026-02-24
**Status:** Approved

## Overview

Add toolkit grouping to config.yaml to simplify machine configuration by grouping related modules under named toolkits. This eliminates repetition when multiple machines need the same set of modules.

## Problem

Currently, every machine must list all modules individually. For common patterns like "terminal setup" (bash, fish, zsh, starship) or "dev tools" (git, nvim, tmux), this creates repetition across machine definitions.

## Solution

Add a `toolkits[]` section to config.yaml that defines named groups of modules. Machines can reference toolkits by name, and the installer will expand them to individual modules before processing.

## Schema Changes

Add a new top-level `toolkits[]` array:

```yaml
modules:
  - name: "bash"
    path: "bash"
  # ... existing modules

toolkits:
  - name: "terminal"
    modules: ["bash", "fish", "zsh", "starship"]
  - name: "editors"
    modules: ["nvim", "vim"]
  - name: "dev"
    modules: ["git", "tmux", "direnv"]

machines:
  - hostname: "HOME-DESKTOP"
    modules:
      - "terminal"           # toolkit reference (expands to 4 modules)
      - "git"                # individual module
      - name: "editors"      # toolkit with target override
        target: "$HOME/.work"
```

**Toolkit definition:**
- `name`: Unique identifier for the toolkit
- `modules`: Array of module names (plain strings only)

**Machine module references:**
- Can mix toolkit and module references
- Plain string: can be either a module or toolkit name
- Object with `name` + `target`: can reference either module or toolkit
- Target override on toolkit applies to ALL modules in that toolkit

**Constraints:**
- Toolkits can only contain module references (no nested toolkits)
- Module names in toolkits must exist in `modules[]` array
- First occurrence of a module wins (duplicates are warned and skipped)

## Processing Logic

### New Functions

1. **`is_toolkit(name)`**
   - Returns 0 if name exists in `toolkits[]`, 1 otherwise
   - Uses yq: `.toolkits[] | select(.name == "$name")`

2. **`get_toolkit_modules(toolkit_name)`**
   - Returns newline-separated list of module names for the toolkit
   - Uses yq: `.toolkits[] | select(.name == "$toolkit_name") | .modules[]`

3. **`expand_machine_modules(hostname)`**
   - Main expansion function
   - Replaces current `get_machine_modules()` usage
   - Algorithm:
     1. Get machine's modules array
     2. For each entry (string or object):
        - Extract name and optional target
        - Check if it's a toolkit
        - If toolkit: expand to individual modules, apply target to all
        - If module: add as-is
        - Track seen modules in associative array
        - If duplicate: warn and skip
     3. Return newline-separated list of unique modules
   - Also populates global `MODULE_TARGETS` associative array

### Target Resolution

**Global state:**
```bash
declare -A MODULE_TARGETS  # Maps module_name -> target_override
```

Populated during `expand_machine_modules()` when:
- Toolkit has target override: all modules get that target
- Individual module has target override: that module gets that target

**Modified `resolve_target()` priority:**
1. Check `MODULE_TARGETS["$module_name"]` first (from expansion)
2. Check machine-level override (existing logic)
3. Check module-level default (existing logic)
4. Default to $HOME (existing logic)

### Integration Point

In `main()`, replace:
```bash
while IFS= read -r mod; do
    [[ -n "$mod" ]] && module_list+=("$mod")
done < <(get_machine_modules "$CURRENT_HOST")
```

With:
```bash
while IFS= read -r mod; do
    [[ -n "$mod" ]] && module_list+=("$mod")
done < <(expand_machine_modules "$CURRENT_HOST")
```

All downstream code (dependency collection, stowing) works unchanged.

## Error Handling

### Validation Checks

1. **Undefined toolkit reference**
   - Warning: "Toolkit 'foo' not found in toolkits[] definitions -- skipping"
   - Add to ERRORS array
   - Continue with remaining modules

2. **Toolkit contains undefined module**
   - Warning: "Module 'bar' in toolkit 'terminal' not found in modules[] -- skipping"
   - Skip that module reference
   - Continue with other toolkit modules

3. **Empty toolkit**
   - Warning: "Toolkit 'terminal' is empty -- skipping"
   - Continue processing

4. **Duplicate module**
   - Warning: "Module 'bash' already included, skipping duplicate reference"
   - First occurrence wins
   - Continue processing

### Backwards Compatibility

- If `toolkits[]` section is missing: no expansion, works as before
- Existing configs with no toolkits: fully compatible
- Machine references unknown name: existing logic handles it
- No breaking changes

## Implementation Notes

### Bash Implementation Details

- Use bash 4+ associative arrays: `declare -A MODULE_TARGETS`
- Use yq for all YAML parsing (consistent with existing code)
- Follow existing error handling patterns (warn, add to ERRORS, continue)
- Follow existing naming conventions (snake_case functions)
- Use existing color logging functions (info, warn, error, success)

### Testing Approach

Manual testing scenarios:
1. Toolkit with 4 modules, verify all expand
2. Mix toolkits and individual modules
3. Toolkit with target override
4. Duplicate module detection (toolkit + individual)
5. Undefined toolkit reference
6. Toolkit containing undefined module
7. Empty config.yaml (backwards compatibility)
8. Machine with no toolkits (backwards compatibility)

## Future Enhancements

Potential future improvements (out of scope for initial implementation):
- Toolkit inheritance or composition
- Per-module overrides within toolkit references
- Validation command to check config.yaml structure
- List command to show expanded module list for a hostname

## Summary

This design adds toolkit grouping to config.yaml through:
1. New `toolkits[]` schema section
2. Early expansion in processing pipeline
3. Duplicate detection with warnings
4. Target override propagation
5. Full backwards compatibility

The implementation is focused on simplicity: expand early, then use existing processing logic unchanged.
