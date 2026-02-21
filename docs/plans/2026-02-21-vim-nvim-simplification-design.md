# Vim/Neovim Configuration Simplification Design

**Date:** 2026-02-21
**Status:** Approved
**Author:** User + Claude Code

## Overview

Simplify vim and nvim configurations by eliminating duplicate package managers while maintaining full VSCode-like features in both editors. The goal is fewer moving parts, easier troubleshooting, faster startup, and less configuration to maintain.

## Background

**Current state:**
- **vim/**: Minimal configuration (line numbers, syntax only)
- **nvim/**: Full featured with lazy.nvim (plugin manager) + mason.nvim (LSP server manager)
- Two package managers in nvim creates complexity and redundancy
- User is transitioning from VSCode and needs LSP autocomplete, file navigation, and AI assistance

**User requirements:**
- Coming from VSCode world, learning nvim
- Need full VSCode-like experience (LSP, autocomplete, file tree, fuzzy finder)
- Want simplicity: fewer moving parts, easy troubleshooting, fast startup, less maintenance
- Want to maintain separate vim config (for machines where only vim is installed)
- Both vim and nvim should mirror each other in structure and features
- Replace avante AI with GitHub Copilot + Gemini CLI integration

## Architecture

### Principle: Single Responsibility

- **Plugin managers** (lazy.nvim, vim-plug): Manage editor plugins only
- **System package manager** (pacman/apt/dnf/brew): Manage LSP servers and tools
- **No mason.nvim**: Redundant when dotfiles system already handles cross-machine binary installation

### Parallel Configurations

Both vim/ and nvim/ will have:
- Similar directory structures
- Similar features (LSP, completion, file navigation, fuzzy finding, AI)
- Different implementations (vim-native vs neovim-native ecosystems)

## Directory Structure

### nvim/
```
nvim/
├── .config/nvim/
│   ├── init.lua                          # Entry point
│   ├── lua/
│   │   ├── config/
│   │   │   ├── lazy.lua                  # Bootstrap lazy.nvim
│   │   │   ├── options.lua               # Editor settings
│   │   │   └── keymap.lua                # Global keymaps
│   │   └── plugins/
│   │       ├── lsp.lua                   # REWRITTEN - no mason
│   │       ├── completion.lua            # nvim-cmp
│   │       ├── telescope.lua             # Fuzzy finder
│   │       ├── neotree.lua               # File tree
│   │       ├── treesitter.lua            # Syntax
│   │       ├── tokyonight.lua            # Theme
│   │       ├── whichkey.lua              # Keybinding hints
│   │       ├── copilot.lua               # NEW - GitHub Copilot
│   │       └── gemini.lua                # NEW - Gemini CLI integration
├── deps.yaml                             # EXPANDED - add LSP servers
└── .stow-local-ignore
```

### vim/
```
vim/
├── .vim/
│   ├── vimrc                             # Main config (NEW)
│   ├── plugin/                           # Plugin configs (NEW)
│   │   ├── lsp.vim                       # coc.nvim config
│   │   ├── fzf.vim                       # Fuzzy finder
│   │   ├── nerdtree.vim                  # File tree
│   │   ├── theme.vim                     # Tokyo Night
│   │   ├── whichkey.vim                  # Keybinding hints
│   │   ├── copilot.vim                   # GitHub Copilot
│   │   └── gemini.vim                    # Gemini CLI integration
│   └── autoload/                         # vim-plug bootstrap (NEW)
│       └── plug.vim
├── deps.yaml                             # NEW - vim + node + LSP servers
└── .stow-local-ignore
```

## Plugin Strategy

### Neovim Stack (lazy.nvim)

**Keep:**
- `neovim/nvim-lspconfig` - LSP client (no mason dependencies)
- `hrsh7th/nvim-cmp` + sources - Autocompletion
- `nvim-telescope/telescope.nvim` - Fuzzy finder
- `nvim-neo-tree/neo-tree.nvim` - File tree
- `nvim-treesitter/nvim-treesitter` - Syntax highlighting
- `folke/tokyonight.nvim` - Theme
- `folke/which-key.nvim` - Keybinding hints

**Remove:**
- `williamboman/mason.nvim` - Replaced by system packages
- `williamboman/mason-lspconfig.nvim` - No longer needed
- Avante plugin - Replaced by Copilot + Gemini

**Add:**
- `github/copilot.vim` - Inline AI suggestions (primary)

### Vim Stack (vim-plug)

**New plugins:**
- `neoclide/coc.nvim` - LSP client + autocompletion (all-in-one)
- `junegunn/fzf.vim` - Fuzzy finder (vim equivalent of telescope)
- `preservim/nerdtree` - File tree (vim equivalent of neo-tree)
- `folke/tokyonight.nvim` - Same theme (works in both)
- `liuchengxu/vim-which-key` - Keybinding hints
- `github/copilot.vim` - Same plugin works for vim

**Key difference:**
- **nvim**: Multiple small plugins, each doing one thing (Unix philosophy)
- **vim**: coc.nvim handles LSP+completion together (simpler, fewer moving parts)

Both achieve the same user experience.

## LSP Server Management

### Shared System Packages

Both vim/deps.yaml and nvim/deps.yaml will include:

```yaml
packages:
  arch:
    - lua-language-server
    - pyright
    - typescript-language-server
    - rust-analyzer
    - gopls
    - bash-language-server
  debian:
    - lua-language-server
    - pyright
    - node-typescript-language-server
    # rust-analyzer, gopls may need manual install
  fedora:
    # similar
  macos:
    # similar (via brew)
```

**vim/ additionally needs:**
```yaml
packages:
  arch:
    - vim
    - nodejs
    - npm
```

**nvim/ needs:**
```yaml
packages:
  arch:
    - neovim
    - ripgrep
    - fd
```

### LSP Configuration

**nvim approach:**
Direct nvim-lspconfig setup without mason handlers:

```lua
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Setup each server manually
lspconfig.lua_ls.setup({ capabilities = capabilities, on_attach = on_attach })
lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach })
-- etc.
```

**vim approach:**
coc.nvim with coc-settings.json declaring language servers:

```json
{
  "languageserver": {
    "lua": {
      "command": "lua-language-server",
      "filetypes": ["lua"]
    }
  }
}
```

## AI Integration Strategy

### GitHub Copilot (Primary)

- **Plugin:** `github/copilot.vim` (works in both vim and nvim)
- **Behavior:** Inline completions as you type
- **Keybinding:** Accept with `Tab` (standard)
- **Setup:** `:Copilot setup` (one-time GitHub authentication)

### Gemini CLI (Secondary)

- **Integration:** Custom keybindings calling gemini CLI
- **Use case:** Command-based AI help for longer interactions
- **Example keybinding:** `<leader>ai` sends selection to gemini, inserts response
- **Implementation:** Shell command wrapper via vim/nvim system()
- **Dependency:** Gemini CLI in PATH (added to deps.yaml with graceful fallback)

```lua
-- nvim example
vim.keymap.set("v", "<leader>ai", function()
  local selection = get_visual_selection()
  local result = vim.fn.system("gemini ask '" .. selection .. "'")
  insert_result(result)
end)
```

## Dependencies (deps.yaml)

### nvim/deps.yaml

```yaml
packages:
  arch:
    - neovim
    - ripgrep
    - fd
    - lua-language-server
    - pyright
    - typescript-language-server
    - rust-analyzer
    - gopls
    - bash-language-server
  debian:
    - neovim
    - ripgrep
    - fd-find
    - lua-language-server
    - pyright
    - node-typescript-language-server
  fedora:
    - neovim
    - ripgrep
    - fd-find
    - lua-language-server
    - pyright
  macos:
    - neovim
    - ripgrep
    - fd
    - lua-language-server
    - pyright
    - typescript-language-server
    - rust-analyzer
    - gopls
    - bash-language-server

script:
  - run: "command -v gemini || echo 'Install gemini CLI manually from Google'"
    provides: gemini
```

### vim/deps.yaml

```yaml
packages:
  arch:
    - vim
    - nodejs
    - npm
    - ripgrep
    - fd
    - lua-language-server
    - pyright
    - typescript-language-server
    - rust-analyzer
    - gopls
    - bash-language-server
  debian:
    - vim
    - nodejs
    - npm
    - ripgrep
    - fd-find
    - lua-language-server
    - pyright
    - node-typescript-language-server
  fedora:
    # similar
  macos:
    # similar

script:
  - run: "command -v gemini || echo 'Install gemini CLI manually from Google'"
    provides: gemini
```

## Migration Strategy

### Pre-migration

1. **Commit current config** (backup point)
2. **Optional cleanup:**
   - `~/.local/share/nvim/mason/` - Old mason LSP servers (can delete)
   - `~/.local/share/nvim/lazy/` - Plugin cache (keep, lazy auto-cleans)

### Migration Steps

1. **Remove avante plugin:**
   - Delete `nvim/.config/nvim/lua/plugins/avante.lua`

2. **Rewrite nvim LSP config:**
   - Rewrite `nvim/.config/nvim/lua/plugins/lsp.lua` without mason
   - Add manual lspconfig setup for each server

3. **Update nvim dependencies:**
   - Edit `nvim/deps.yaml` to include all LSP servers

4. **Create vim structure:**
   - Build `vim/.vim/` directory with vimrc and plugin configs
   - Create `vim/deps.yaml`

5. **Add AI plugins:**
   - Create `nvim/.config/nvim/lua/plugins/copilot.lua`
   - Create `nvim/.config/nvim/lua/plugins/gemini.lua`
   - Create equivalent vim plugin configs

6. **Install:**
   ```bash
   ./install.sh
   ```
   - Installs all LSP servers via system package manager
   - Stows both vim and nvim configs

7. **Bootstrap plugins:**
   - Open nvim → lazy.nvim auto-installs plugins
   - Open vim → vim-plug auto-installs plugins
   - Run `:Copilot setup` in both editors (GitHub auth)

### Testing Checklist

- [ ] nvim starts without errors
- [ ] vim starts without errors
- [ ] LSP works in nvim (gd, K, diagnostics, hover)
- [ ] LSP works in vim (gd, K, diagnostics, hover)
- [ ] Completion works in nvim (type and get suggestions)
- [ ] Completion works in vim (type and get suggestions)
- [ ] File navigation: Telescope in nvim
- [ ] File navigation: FZF in vim
- [ ] File tree: neo-tree in nvim
- [ ] File tree: NERDTree in vim
- [ ] Copilot activates in nvim (inline suggestions)
- [ ] Copilot activates in vim (inline suggestions)
- [ ] Gemini CLI accessible via custom keybinding in both
- [ ] Both editors use same LSP servers (verify with `:LspInfo` in nvim, `:CocInfo` in vim)

### Rollback Plan

- Git keeps old config
- `git revert` or `git reset --hard` to previous commit if issues arise

## Expected Improvements

### Fewer Moving Parts
- **Before:** lazy.nvim + mason.nvim + system packages
- **After:** lazy.nvim (or vim-plug) + system packages
- One clear package manager per responsibility

### Easy Troubleshooting
- **Before:** LSP servers hidden in `~/.local/share/nvim/mason/bin/`
- **After:** LSP servers in system PATH (`/usr/bin/`, `/usr/local/bin/`)
- Standard `which lua-language-server` debugging

### Faster Startup
- **Before:** Mason checks for updates, manages versions
- **After:** Direct lspconfig connection to system binaries
- No extra mason initialization overhead

### Less Maintenance
- **Before:** `./install.sh` + `:MasonUpdate` + lazy updates
- **After:** `./install.sh` handles everything (system packages + stow)
- Plugin updates still via lazy/vim-plug (as before)

### Consistency
- Same LSP features in both vim and nvim
- Same AI integrations (Copilot + Gemini)
- Same workflow whether you type `vim` or `nvim`

## Trade-offs

### Advantages
- Simpler mental model (one package system per domain)
- Faster to provision new machines (parallel installs via system PM)
- Easier to debug (standard system paths)
- Consistent with existing dotfiles philosophy

### Disadvantages
- Can't install LSP servers per-project (system-wide only)
  - **Mitigation:** Most users want system-wide anyway; project-specific servers can use direnv if needed
- Requires system package manager support for all LSP servers
  - **Mitigation:** All major servers available on major distros; rare servers can use cargo/npm in deps.yaml
- Manual LSP config vs mason's auto-setup
  - **Mitigation:** ~10 lines per server, rarely changes, clearer than magic handlers

## Alternatives Considered

### Single-file minimal config
**Rejected:** User wants full VSCode-like features, not minimalism

### No plugin manager (native packages)
**Rejected:** Awkward to maintain, poor update story

### Vim with same Lua plugins
**Rejected:** Vim doesn't have Lua support; separate ecosystems are appropriate

### Keep mason, remove lazy
**Rejected:** Lazy is excellent for plugin management, mason is the redundant one

## Success Criteria

1. User can install vim or nvim independently via `./install.sh`
2. Both editors provide LSP, completion, navigation, AI features
3. Startup time is noticeably faster in nvim
4. User understands what each component does
5. No duplicate package managers per editor
6. Easy to add new LSP servers (edit deps.yaml, run install.sh)

## Future Considerations

- Consider sharing common LSP config between vim and nvim (symlink or generated)
- Explore direnv integration for project-specific LSP server versions if needed
- Document per-language LSP server setup in separate guides
- Consider adding linters/formatters to deps.yaml (ruff, black, prettier, etc.)

## Conclusion

This design achieves simplification by eliminating mason.nvim and leveraging the existing dotfiles installation system. Both vim and nvim get modern IDE-like features while maintaining clear separation of concerns: plugin managers handle plugins, system package manager handles binaries. The result is faster, easier to understand, and easier to maintain.
