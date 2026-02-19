# Yazi Module Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a yazi terminal file manager dotfiles module with Tokyo Night theming, sensible defaults, and plugin support.

**Architecture:** Standard stow module at `yazi/.config/yazi/` deploying to `~/.config/yazi/`. Four config files: `yazi.toml` (behavior), `keymap.toml` (keybindings), `theme.toml` (Tokyo Night colors), `init.lua` (git plugin). Registered in `config.yaml` for all hosts.

**Tech Stack:** TOML config, Lua (init.lua), GNU Stow

---

### Task 1: Create module directory and stow ignore

**Files:**
- Create: `yazi/.config/yazi/` (directory)
- Create: `yazi/.stow-local-ignore`

**Step 1: Create directory structure**

```bash
mkdir -p yazi/.config/yazi
```

**Step 2: Create `.stow-local-ignore`**

Write `yazi/.stow-local-ignore`:

```
# Files and patterns to ignore when stowing this module
# Documentation files that should stay in the repository

README\.md
.*\.md$

# Common documentation and repository files
LICENSE
CHANGELOG
\.git
\.gitignore

# Module metadata (not deployed to target)
deps\.yaml
```

**Step 3: Verify structure**

```bash
ls -la yazi/.config/yazi/
cat yazi/.stow-local-ignore
```

Expected: directory exists, ignore file matches content above.

---

### Task 2: Create `yazi.toml` main configuration

**Files:**
- Create: `yazi/.config/yazi/yazi.toml`

**Step 1: Write `yazi.toml`**

```toml
# Yazi File Manager Configuration
# Theme: Tokyo Night Cyberpunk
# Docs: https://yazi-rs.github.io/docs/configuration/yazi

# ============================================================================
# Manager
# ============================================================================
[mgr]
ratio        = [1, 4, 3]
sort_by      = "natural"
sort_sensitive = false
sort_reverse = false
sort_dir_first = true
linemode     = "size"
show_hidden  = false
show_symlink = true
scrolloff    = 5
title_format = "Yazi: {cwd}"

# ============================================================================
# Preview
# ============================================================================
[preview]
wrap       = "no"
tab_size   = 2
max_width  = 600
max_height = 900
image_filter  = "lanczos3"
image_quality = 75

# ============================================================================
# Opener
# ============================================================================
[opener]
edit = [
	{ run = "${EDITOR:-vim} \"$@\"", block = true, desc = "Edit", for = "unix" },
]
open = [
	{ run = "xdg-open \"$@\"", desc = "Open", for = "linux" },
	{ run = "open \"$@\"", desc = "Open", for = "macos" },
]
extract = [
	{ run = "ya pub extract --list \"$@\"", desc = "Extract here" },
]

# ============================================================================
# Open rules
# ============================================================================
[open]
prepend_rules = [
	{ mime = "text/*", use = ["edit", "open"] },
	{ mime = "inode/x-empty", use = ["edit", "open"] },

	{ mime = "application/json", use = ["edit", "open"] },
	{ mime = "*/javascript", use = ["edit", "open"] },
	{ mime = "*/x-{shellscript,python,lua,perl,ruby}", use = ["edit", "open"] },

	{ mime = "image/*", use = ["open", "edit"] },
	{ mime = "{audio,video}/*", use = ["open"] },
	{ mime = "application/{zip,gzip,x-tar,x-bzip2,x-7z-compressed,x-rar,x-xz,zstd}", use = ["extract", "open"] },

	{ mime = "application/pdf", use = ["open"] },
]

# ============================================================================
# Plugin previewers (extend defaults)
# ============================================================================
[plugin]
prepend_previewers = []
prepend_preloaders = []
```

**Step 2: Verify syntax**

```bash
cat yazi/.config/yazi/yazi.toml
```

Expected: valid TOML with all sections present.

---

### Task 3: Create `theme.toml` with Tokyo Night palette

**Files:**
- Create: `yazi/.config/yazi/theme.toml`

**Step 1: Write `theme.toml`**

Use the exact Tokyo Night palette from the existing modules (kitty, starship, waybar):

```toml
# Yazi Theme Configuration
# Theme: Tokyo Night Cyberpunk
# Palette consistent with kitty, starship, waybar, rofi, hyprland

# ============================================================================
# Manager
# ============================================================================
[mgr]
cwd = { fg = "#7aa2f7" }

# Highlight
hovered         = { fg = "#c0caf5", bg = "#292e42" }
preview_hovered = { fg = "#c0caf5", bg = "#292e42" }

# Find
find_keyword  = { fg = "#e0af68", bold = true }
find_position = { fg = "#bb9af7", italic = true }

# Marker
marker_selected = { fg = "#9ece6a", bg = "#9ece6a" }
marker_copied   = { fg = "#e0af68", bg = "#e0af68" }
marker_cut      = { fg = "#f7768e", bg = "#f7768e" }

# Tab
tab_active   = { fg = "#1a1b26", bg = "#7aa2f7" }
tab_inactive = { fg = "#565f89", bg = "#24283b" }
tab_width    = 1

# Border
border_symbol = "│"
border_style  = { fg = "#565f89" }

# ============================================================================
# Status Bar
# ============================================================================
[status]
sep_left  = { open = "", close = "" }
sep_right = { open = "", close = "" }

# Mode
mode_normal = { fg = "#1a1b26", bg = "#7aa2f7", bold = true }
mode_select = { fg = "#1a1b26", bg = "#9ece6a", bold = true }
mode_unset  = { fg = "#1a1b26", bg = "#f7768e", bold = true }

# Progress
progress_label  = { fg = "#c0caf5", bold = true }
progress_normal = { fg = "#7aa2f7", bg = "#24283b" }
progress_error  = { fg = "#f7768e", bg = "#24283b" }

# Permissions
perm_type  = { fg = "#7aa2f7" }
perm_read  = { fg = "#e0af68" }
perm_write = { fg = "#f7768e" }
perm_exec  = { fg = "#9ece6a" }
perm_sep   = { fg = "#565f89" }

# ============================================================================
# File Types
# ============================================================================
[filetype]
rules = [
	# Directories
	{ mime = "inode/directory", fg = "#7aa2f7", bold = true },

	# Images
	{ mime = "image/*", fg = "#e0af68" },

	# Audio & Video
	{ mime = "{audio,video}/*", fg = "#bb9af7" },

	# Archives
	{ mime = "application/{zip,gzip,x-tar,x-bzip2,x-7z-compressed,x-rar,x-xz,zstd}", fg = "#f7768e" },

	# Documents
	{ mime = "application/pdf", fg = "#ff9e64" },

	# Symlinks
	{ name = "*", is = "link", fg = "#7dcfff", italic = true },

	# Executables
	{ name = "*", is = "exec", fg = "#9ece6a" },

	# Orphan (broken symlinks)
	{ name = "*", is = "orphan", fg = "#f7768e", italic = true },
]

# ============================================================================
# Input
# ============================================================================
[input]
border   = { fg = "#7aa2f7" }
title    = { fg = "#c0caf5" }
value    = { fg = "#c0caf5" }
selected = { reversed = true }

# ============================================================================
# Completion
# ============================================================================
[cmp]
border   = { fg = "#565f89" }
active   = { fg = "#c0caf5", bg = "#292e42" }
inactive = { fg = "#565f89" }

# ============================================================================
# Help
# ============================================================================
[help]
on      = { fg = "#7aa2f7" }
run     = { fg = "#bb9af7" }
desc    = { fg = "#a9b1d6" }
hovered = { reversed = true, bold = true }
footer  = { fg = "#565f89" }

# ============================================================================
# Notify
# ============================================================================
[notify]
title_info  = { fg = "#9ece6a" }
title_warn  = { fg = "#e0af68" }
title_error = { fg = "#f7768e" }
```

---

### Task 4: Create `keymap.toml` with practical keybindings

**Files:**
- Create: `yazi/.config/yazi/keymap.toml`

**Step 1: Write `keymap.toml`**

Uses `prepend_keymap` to add bindings without overriding defaults:

```toml
# Yazi Keymap Configuration
# Only prepend custom bindings — all defaults are preserved
# Docs: https://yazi-rs.github.io/docs/configuration/keymap

# ============================================================================
# Manager keybindings
# ============================================================================
[mgr]
prepend_keymap = [
	# Shell
	{ on = [ "!" ], run = "shell \"$SHELL\" --block --confirm", desc = "Open shell here" },

	# Archive extraction
	{ on = [ "E" ], run = "plugin extract", desc = "Extract archive" },

	# Quick navigation
	{ on = [ "g", "d" ], run = "cd ~/Downloads", desc = "Go to Downloads" },
	{ on = [ "g", "c" ], run = "cd ~/.config", desc = "Go to .config" },
	{ on = [ "g", "D" ], run = "cd ~/.local/share/dotfiles", desc = "Go to dotfiles" },

	# Zoxide integration
	{ on = [ "z" ], run = "plugin zoxide", desc = "Jump via zoxide" },
]
```

---

### Task 5: Create `init.lua` for plugin initialization

**Files:**
- Create: `yazi/.config/yazi/init.lua`

**Step 1: Write `init.lua`**

```lua
-- Yazi Plugin Initialization
-- Git status integration for file list

-- Show git file status (modified, untracked, etc.) in linemode
-- Requires: git
require("git"):setup()
```

---

### Task 6: Register module in config.yaml

**Files:**
- Modify: `config.yaml`

**Step 1: Add yazi entry to config.yaml**

Add after the `fonts` entry (last module) in `config.yaml`:

```yaml
  - name: "yazi"
    path: "yazi"
    hosts:
      - HOME-DESKTOP
      - ASUS-LAPTOP
      - WORK-MACBOOK
      - CODESPACES
      - asus-vivobook
      - DESKTOP-OKTKL4S
```

**Step 2: Verify YAML syntax**

```bash
yq '.' config.yaml > /dev/null && echo "valid YAML"
```

Expected: `valid YAML`

---

### Task 7: Verify and commit

**Step 1: Verify full module structure**

```bash
find yazi/ -type f | sort
```

Expected:
```
yazi/.config/yazi/init.lua
yazi/.config/yazi/keymap.toml
yazi/.config/yazi/theme.toml
yazi/.config/yazi/yazi.toml
yazi/.stow-local-ignore
```

**Step 2: Dry-run stow**

```bash
cd ~/.local/share/dotfiles && stow -n -v yazi 2>&1
```

Expected: shows what symlinks would be created, no errors.

**Step 3: Commit**

```bash
git add yazi/ config.yaml docs/plans/2026-02-19-yazi-module-design.md docs/plans/2026-02-19-yazi-module-plan.md
git commit -m "feat: add yazi file manager module with Tokyo Night theme"
```
