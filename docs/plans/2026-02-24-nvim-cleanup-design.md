# Neovim Configuration Cleanup Design

**Date:** 2026-02-24
**Goal:** Complete cleanup and rebuild of nvim configuration with a minimal, modular approach

## Overview

This design replaces the existing nvim configuration with a clean, minimal setup that preserves all essential IDE features while removing bloat, fixing diagnostics issues, and improving maintainability.

## Requirements

**Essential Features:**
- LSP support for Python, TypeScript/JavaScript, Go, Rust, Lua, Bash
- Fuzzy finding (files and content search)
- File tree navigation
- Syntax highlighting via Treesitter
- Tokyo Night color scheme
- Keymap discoverability via which-key

**Key Issues to Resolve:**
- Lua diagnostics warnings about undefined `vim` global
- Empty plugin configs (treesitter, neotree dependencies)
- Unused plugins (nvim-lsp-file-operations, nvim-window-picker)
- Lack of comprehensive keymap documentation

## Architecture

### Directory Structure

```
nvim/
├── .config/nvim/
│   ├── init.lua                    # Entry point
│   ├── lua/
│   │   ├── config/
│   │   │   ├── lazy.lua           # Plugin manager bootstrap
│   │   │   ├── options.lua        # Editor settings
│   │   │   └── keymaps.lua        # General keybindings
│   │   └── plugins/
│   │       ├── colorscheme.lua    # Tokyo Night theme
│   │       ├── treesitter.lua     # Syntax highlighting
│   │       ├── telescope.lua      # Fuzzy finder
│   │       ├── neotree.lua        # File explorer
│   │       ├── completion.lua     # nvim-cmp + snippets
│   │       ├── lsp.lua            # LSP configuration
│   │       └── whichkey.lua       # Keymap hints
├── keybindings.md                  # Comprehensive keymap reference
└── deps.yaml                       # System dependencies (unchanged)
```

### Loading Order

1. `init.lua` loads config modules: lazy → options → keymaps
2. Lazy.nvim auto-imports all files from `plugins/`
3. Each plugin file is self-contained with configuration

### Design Principles

- **One concern per file** - Easy to locate and modify specific functionality
- **No empty configs** - Every plugin gets proper configuration
- **Self-documenting** - Descriptive names and clear structure
- **Minimal but complete** - Only essential plugins, fully configured

## Plugin Specifications

### Core Plugins (8 total)

1. **folke/lazy.nvim**
   - Plugin manager (bootstrapped automatically)
   - Spec imports from `plugins/` directory

2. **folke/tokyonight.nvim**
   - Color scheme matching Starship prompt
   - Variant: tokyonight-night

3. **nvim-treesitter/nvim-treesitter**
   - Syntax highlighting and code understanding
   - Auto-install parsers: python, typescript, javascript, tsx, go, rust, lua, bash, markdown, json, yaml
   - Enable: highlighting, indentation, incremental selection

4. **nvim-telescope/telescope.nvim**
   - Fuzzy finder for files and content
   - Keymaps: `<leader>ff` (files), `<leader>fg` (grep), `<leader>fb` (buffers), `<leader>fh` (help)
   - Dependencies: plenary.nvim

5. **nvim-neo-tree/neo-tree.nvim**
   - File tree explorer
   - Toggle with `<C-n>`
   - Dependencies: plenary.nvim, nui.nvim, nvim-web-devicons

6. **hrsh7th/nvim-cmp**
   - Completion engine
   - Sources: LSP, buffer, path, snippets
   - Tab/S-Tab for navigation, CR to confirm
   - Dependencies: cmp-nvim-lsp, cmp-buffer, cmp-path, LuaSnip, cmp_luasnip

7. **neovim/nvim-lspconfig**
   - LSP integration for all languages
   - Modern API: `vim.lsp.config()` + `vim.lsp.enable()` (Neovim 0.10+)
   - Servers: lua_ls, pyright, ts_ls, rust_analyzer, gopls, bashls
   - Buffer-local keymaps on attach

8. **folke/which-key.nvim**
   - Keymap hints and discoverability
   - Leader group labels: `<leader>f` (Find), `<leader>c` (Code), `<leader>r` (Rename)
   - Trigger with `<leader>?`

### Removed Plugins

- nvim-lsp-file-operations (unused)
- nvim-window-picker (unused)

## Configuration Details

### Editor Options (options.lua)

**Line Numbers:**
- Absolute and relative line numbers

**Indentation:**
- 2 spaces, expandtab
- Auto and smart indent

**Search:**
- Smart case-insensitive
- Highlight and incremental search

**Display:**
- No line wrapping
- 8 line scrolloff
- Cursorline highlight
- True color support
- Sign column always visible

**Splits:**
- Open below and right

**Miscellaneous:**
- Persistent undo
- Fast updatetime (250ms)
- Completion menu settings

### General Keymaps (keymaps.lua)

**Leader Keys:**
- Leader: Space
- LocalLeader: Backslash

**Window Navigation:**
- `<C-h/j/k/l>` - Move to left/down/up/right window

**Visual Line Movement:**
- `J`/`K` - Move lines down/up in visual mode

**Centered Scrolling:**
- `<C-d>`/`<C-u>` - Scroll down/up with centered cursor

**Centered Search:**
- `n`/`N` - Next/previous search result (centered)

**Search Management:**
- `<Esc>` - Clear search highlights

**Clipboard Operations:**
- `<leader>y` - Yank to system clipboard
- `<leader>Y` - Yank line to system clipboard
- `<leader>p` - Paste without overwriting register (visual mode)
- `<leader>d` - Delete to void register

**File Operations:**
- `<leader>w` - Quick save

**Diagnostics:**
- `[d` - Previous diagnostic
- `]d` - Next diagnostic
- `<leader>e` - Show diagnostic float

### LSP Configuration (lsp.lua)

**Modern API Usage:**
- Use `vim.lsp.config()` to define server configurations
- Use `vim.lsp.enable()` to activate servers
- Requires Neovim 0.10+

**Capabilities:**
- Integrate with nvim-cmp for autocompletion support

**Common on_attach Function:**
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover documentation
- `gi` - Go to implementation
- `<C-k>` - Signature help
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>f` - Format document (async)

**Lua LSP Special Configuration:**
- Configure vim globals to eliminate "undefined global `vim`" diagnostics
- Workspace library includes Neovim runtime files
- Telemetry disabled

**Language Servers:**
- lua_ls (Lua)
- pyright (Python)
- ts_ls (TypeScript/JavaScript)
- rust_analyzer (Rust)
- gopls (Go)
- bashls (Bash)

### Treesitter Configuration (treesitter.lua)

**Auto-install Parsers:**
- python, typescript, javascript, tsx, go, rust, lua, bash
- markdown, json, yaml (for documentation)

**Features:**
- Syntax highlighting
- Smart indentation
- Incremental selection

### Which-key Configuration (whichkey.lua)

**Group Labels:**
- `<leader>f` - Find (Telescope commands)
- `<leader>c` - Code (LSP actions)
- `<leader>r` - Rename (LSP rename)

**Appearance:**
- Rounded borders

**Activation:**
- `<leader>?` - Show buffer-local keymaps

## Documentation

### keybindings.md

Comprehensive markdown file documenting ALL keybindings in the nvim configuration. Located at module root (`nvim/keybindings.md`) for easy access.

**Sections:**
1. Leader key configuration
2. General editor keymaps
3. Window navigation
4. Visual mode operations
5. Search and navigation
6. Clipboard operations
7. Diagnostics
8. Telescope (fuzzy finder)
9. Neo-tree (file explorer)
10. LSP keymaps (buffer-local)
11. Completion engine
12. Which-key

Each keymap includes:
- Key combination
- Mode (normal, visual, insert)
- Description
- Context (global vs buffer-local)

## Dependencies

### System Packages (deps.yaml)

**No changes required** - existing deps.yaml is correct.

**Required packages:**
- neovim (0.10+)
- ripgrep (for Telescope live_grep)
- fd (for Telescope find_files)
- lua-language-server
- pyright
- typescript-language-server
- rust-analyzer
- gopls
- bash-language-server

Platform-specific variations already documented in deps.yaml.

## Migration Strategy

### Clean Slate Approach

1. **Delete all files** in `nvim/.config/nvim/`
2. **Rewrite from scratch** with new minimal structure
3. **Keep unchanged:** `nvim/deps.yaml`
4. **Add new:** `nvim/keybindings.md`

### Files to Create

All new files with clean implementations:
- init.lua
- lua/config/lazy.lua
- lua/config/options.lua
- lua/config/keymaps.lua
- lua/plugins/colorscheme.lua
- lua/plugins/treesitter.lua
- lua/plugins/telescope.lua
- lua/plugins/neotree.lua
- lua/plugins/completion.lua
- lua/plugins/lsp.lua
- lua/plugins/whichkey.lua
- keybindings.md

### Backup & Safety

- Installer backs up conflicts to `~/.dotfiles-backup/<timestamp>/`
- Lazy.nvim stores state in `~/.local/share/nvim/`
- Lazy will auto-clean removed plugins and install new ones on first launch

### Post-Migration Steps

1. Run `./install.sh` to stow the new configuration
2. Launch nvim - lazy.nvim will auto-install plugins
3. Verify LSP servers are working (`:LspInfo`)
4. Verify Treesitter parsers installed (`:TSInstallInfo`)
5. Test all keybindings

## Success Criteria

- [ ] All Lua diagnostics warnings resolved
- [ ] All plugins have non-empty, functional configurations
- [ ] LSP working for all 6 languages
- [ ] Fuzzy finding operational (files and grep)
- [ ] File tree functional
- [ ] Syntax highlighting active
- [ ] All keybindings documented in keybindings.md
- [ ] Which-key shows helpful hints
- [ ] Clean startup with no errors
- [ ] Total config under 600 lines

## Benefits

**Maintainability:**
- Clear structure - easy to find and modify anything
- Self-contained plugin configs
- Comprehensive documentation

**Reliability:**
- No empty configs or unused plugins
- Proper error handling in LSP setup
- Modern Neovim APIs

**Usability:**
- Complete IDE features preserved
- Keymap documentation for reference
- Which-key for discoverability

**Performance:**
- Minimal plugin count (8 total)
- Lazy loading where appropriate
- No unnecessary dependencies
