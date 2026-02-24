# Neovim Configuration Cleanup Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Clean up and rebuild nvim configuration with minimal modular architecture

**Architecture:** Modular structure with separate config/ and plugins/ directories. Each plugin gets its own file with complete configuration. Modern Neovim 0.10+ LSP API with system-installed language servers.

**Tech Stack:** Neovim 0.10+, lazy.nvim, nvim-lspconfig, nvim-cmp, Telescope, Neo-tree, Treesitter, Tokyo Night, which-key

---

## Task 1: Clean Up Existing Configuration

**Files:**
- Delete: All files in `nvim/.config/nvim/`

**Step 1: Remove existing config files**

Run:
```bash
cd /home/anirudh/.local/share/dotfiles/nvim/.config/nvim
rm -rf lua/ init.lua .luarc.json
```

Expected: All config files removed, only empty nvim/.config/nvim/ directory remains

**Step 2: Verify clean slate**

Run:
```bash
ls -la /home/anirudh/.local/share/dotfiles/nvim/.config/nvim/
```

Expected: Empty directory (or just . and ..)

---

## Task 2: Create Config Infrastructure

**Files:**
- Create: `nvim/.config/nvim/init.lua`
- Create: `nvim/.config/nvim/lua/config/lazy.lua`
- Create: `nvim/.config/nvim/lua/config/options.lua`
- Create: `nvim/.config/nvim/lua/config/keymaps.lua`

**Step 1: Create init.lua**

Create file at `nvim/.config/nvim/init.lua`:

```lua
-- Load lazy.nvim (plugin manager + leader keys)
require("config.lazy")

-- Load editor options
require("config.options")

-- Load keymaps
require("config.keymaps")
```

**Step 2: Create lazy.nvim bootstrap**

Create file at `nvim/.config/nvim/lua/config/lazy.lua`:

```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before lazy setup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  install = { colorscheme = { "tokyonight-night" } },
  checker = { enabled = true },
})
```

**Step 3: Create editor options**

Create file at `nvim/.config/nvim/lua/config/options.lua`:

```lua
-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Display
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Miscellaneous
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menuone,noselect"
```

**Step 4: Create general keymaps**

Create file at `nvim/.config/nvim/lua/config/keymaps.lua`:

```lua
local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Keep cursor centered when scrolling
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })

-- Keep cursor centered when searching
map("n", "n", "nzzzv", { desc = "Next search result (centered)" })
map("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Clear search highlights
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Better paste (don't overwrite register)
map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })

-- Copy to system clipboard
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Delete to void register
map({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete to void register" })

-- Quick save
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })
```

**Step 5: Test config infrastructure**

Run:
```bash
cd /home/anirudh/.local/share/dotfiles
nvim --headless "+qa" 2>&1 | head -20
```

Expected: No errors, lazy.nvim will bootstrap and warn about missing plugins (normal)

**Step 6: Commit config infrastructure**

Run:
```bash
git add nvim/.config/nvim/init.lua nvim/.config/nvim/lua/config/
git commit -m "feat(nvim): add config infrastructure with lazy.nvim bootstrap

- Add init.lua entry point
- Bootstrap lazy.nvim with leader key setup
- Configure editor options (line numbers, indentation, search, display)
- Add general keymaps (window nav, visual line movement, clipboard ops)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Create Colorscheme Plugin

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/colorscheme.lua`

**Step 1: Write colorscheme plugin**

Create file at `nvim/.config/nvim/lua/plugins/colorscheme.lua`:

```lua
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    vim.cmd([[colorscheme tokyonight-night]])
  end,
}
```

**Step 2: Test colorscheme loads**

Run:
```bash
nvim --headless "+lua print(vim.g.colors_name)" "+qa" 2>&1 | grep -i tokyo
```

Expected: Output shows "tokyonight-night" or similar confirmation

**Step 3: Commit colorscheme**

Run:
```bash
git add nvim/.config/nvim/lua/plugins/colorscheme.lua
git commit -m "feat(nvim): add Tokyo Night colorscheme

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Create Treesitter Plugin

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/treesitter.lua`

**Step 1: Write treesitter plugin**

Create file at `nvim/.config/nvim/lua/plugins/treesitter.lua`:

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "python",
        "typescript",
        "javascript",
        "tsx",
        "go",
        "rust",
        "lua",
        "bash",
        "markdown",
        "json",
        "yaml",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<CR>",
          node_incremental = "<CR>",
          scope_incremental = "<TAB>",
          node_decremental = "<S-TAB>",
        },
      },
    })
  end,
}
```

**Step 2: Test treesitter configuration**

Run:
```bash
nvim --headless "+lua require('nvim-treesitter.configs').setup({})" "+qa" 2>&1 | grep -i error
```

Expected: No errors (empty output or success messages)

**Step 3: Commit treesitter**

Run:
```bash
git add nvim/.config/nvim/lua/plugins/treesitter.lua
git commit -m "feat(nvim): add treesitter with syntax highlighting

Configure treesitter for Python, TypeScript, Go, Rust, Lua, Bash
Enable highlighting, indentation, and incremental selection

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Create Telescope Plugin

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/telescope.lua`

**Step 1: Write telescope plugin**

Create file at `nvim/.config/nvim/lua/plugins/telescope.lua`:

```lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
  end,
}
```

**Step 2: Test telescope configuration**

Run:
```bash
nvim --headless "+lua require('telescope')" "+qa" 2>&1 | grep -i error
```

Expected: No errors

**Step 3: Commit telescope**

Run:
```bash
git add nvim/.config/nvim/lua/plugins/telescope.lua
git commit -m "feat(nvim): add telescope fuzzy finder

Configure keymaps:
- <leader>ff: find files
- <leader>fg: live grep
- <leader>fb: buffers
- <leader>fh: help tags

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Create Neo-tree Plugin

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/neotree.lua`

**Step 1: Write neotree plugin**

Create file at `nvim/.config/nvim/lua/plugins/neotree.lua`:

```lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      window = {
        width = 30,
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
    })

    vim.keymap.set("n", "<C-n>", "<Cmd>Neotree toggle<CR>", { desc = "Toggle Neo-tree" })
  end,
}
```

**Step 2: Test neotree configuration**

Run:
```bash
nvim --headless "+lua require('neo-tree')" "+qa" 2>&1 | grep -i error
```

Expected: No errors

**Step 3: Commit neotree**

Run:
```bash
git add nvim/.config/nvim/lua/plugins/neotree.lua
git commit -m "feat(nvim): add neo-tree file explorer

Configure with <C-n> toggle keybind
Enable current file following and auto-refresh

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Create Completion Plugin

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/completion.lua`

**Step 1: Write completion plugin**

Create file at `nvim/.config/nvim/lua/plugins/completion.lua`:

```lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}
```

**Step 2: Test completion configuration**

Run:
```bash
nvim --headless "+lua require('cmp')" "+qa" 2>&1 | grep -i error
```

Expected: No errors

**Step 3: Commit completion**

Run:
```bash
git add nvim/.config/nvim/lua/plugins/completion.lua
git commit -m "feat(nvim): add nvim-cmp completion engine

Configure with LSP, buffer, path, and snippet sources
Tab/S-Tab navigation, CR to confirm

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Create LSP Plugin

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/lsp.lua`

**Step 1: Write LSP plugin**

Create file at `nvim/.config/nvim/lua/plugins/lsp.lua`:

```lua
return {
  "neovim/nvim-lspconfig",
  config = function()
    -- Build capabilities with cmp integration
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    -- Common on_attach for LSP keymaps
    local on_attach = function(_, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, opts)
    end

    -- Lua
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    -- Python
    vim.lsp.config("pyright", {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable("pyright")

    -- TypeScript/JavaScript
    vim.lsp.config("ts_ls", {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable("ts_ls")

    -- Rust
    vim.lsp.config("rust_analyzer", {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable("rust_analyzer")

    -- Go
    vim.lsp.config("gopls", {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable("gopls")

    -- Bash
    vim.lsp.config("bashls", {
      capabilities = capabilities,
      on_attach = on_attach,
    })
    vim.lsp.enable("bashls")
  end,
}
```

**Step 2: Test LSP configuration**

Run:
```bash
nvim --headless "+lua require('lspconfig')" "+qa" 2>&1 | grep -i error
```

Expected: No errors

**Step 3: Commit LSP configuration**

Run:
```bash
git add nvim/.config/nvim/lua/plugins/lsp.lua
git commit -m "feat(nvim): add LSP configuration for 6 languages

Configure LSP servers: lua_ls, pyright, ts_ls, rust_analyzer, gopls, bashls
Use modern vim.lsp.config/enable API
Add buffer-local keymaps on attach (gd, gr, K, ca, rn, f)
Fix vim global diagnostics for Lua LSP

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Create Which-key Plugin

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/whichkey.lua`

**Step 1: Write which-key plugin**

Create file at `nvim/.config/nvim/lua/plugins/whichkey.lua`:

```lua
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
    },
    win = {
      border = "rounded",
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps",
    },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Register group labels
    wk.add({
      { "<leader>f", group = "Find" },
      { "<leader>c", group = "Code" },
      { "<leader>r", group = "Rename" },
    })
  end,
}
```

**Step 2: Test which-key configuration**

Run:
```bash
nvim --headless "+lua require('which-key')" "+qa" 2>&1 | grep -i error
```

Expected: No errors

**Step 3: Commit which-key**

Run:
```bash
git add nvim/.config/nvim/lua/plugins/whichkey.lua
git commit -m "feat(nvim): add which-key for keymap discovery

Configure with rounded borders and leader group labels
<leader>?: show buffer-local keymaps

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 10: Create Keybindings Documentation

**Files:**
- Create: `nvim/keybindings.md`

**Step 1: Write keybindings documentation**

Create file at `nvim/keybindings.md`:

```markdown
# Neovim Keybindings Reference

## Leader Keys

- **Leader:** `Space`
- **LocalLeader:** `\`

## General Editor Keymaps

### Window Navigation
| Key | Mode | Description |
|-----|------|-------------|
| `<C-h>` | Normal | Move to left window |
| `<C-j>` | Normal | Move to lower window |
| `<C-k>` | Normal | Move to upper window |
| `<C-l>` | Normal | Move to right window |

### Visual Mode Line Movement
| Key | Mode | Description |
|-----|------|-------------|
| `J` | Visual | Move selected lines down |
| `K` | Visual | Move selected lines up |

### Scrolling (Centered)
| Key | Mode | Description |
|-----|------|-------------|
| `<C-d>` | Normal | Scroll down half-page (cursor centered) |
| `<C-u>` | Normal | Scroll up half-page (cursor centered) |

### Search Navigation (Centered)
| Key | Mode | Description |
|-----|------|-------------|
| `n` | Normal | Next search result (cursor centered) |
| `N` | Normal | Previous search result (cursor centered) |
| `<Esc>` | Normal | Clear search highlights |

### Clipboard Operations
| Key | Mode | Description |
|-----|------|-------------|
| `<leader>y` | Normal, Visual | Yank to system clipboard |
| `<leader>Y` | Normal | Yank entire line to system clipboard |
| `<leader>p` | Visual | Paste without overwriting register |
| `<leader>d` | Normal, Visual | Delete to void register (no clipboard) |

### File Operations
| Key | Mode | Description |
|-----|------|-------------|
| `<leader>w` | Normal | Quick save current file |

## Diagnostics

| Key | Mode | Description |
|-----|------|-------------|
| `[d` | Normal | Go to previous diagnostic |
| `]d` | Normal | Go to next diagnostic |
| `<leader>e` | Normal | Show diagnostic in floating window |

## Telescope (Fuzzy Finder)

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>ff` | Normal | Find files in project |
| `<leader>fg` | Normal | Live grep (search in files) |
| `<leader>fb` | Normal | Find open buffers |
| `<leader>fh` | Normal | Search help tags |

## Neo-tree (File Explorer)

| Key | Mode | Description |
|-----|------|-------------|
| `<C-n>` | Normal | Toggle Neo-tree file explorer |

## LSP (Language Server Protocol)

**Note:** These keymaps are buffer-local and only active when an LSP server is attached to the current buffer.

| Key | Mode | Description |
|-----|------|-------------|
| `gd` | Normal | Go to definition |
| `gr` | Normal | Find references |
| `gi` | Normal | Go to implementation |
| `K` | Normal | Show hover documentation |
| `<C-k>` | Normal | Show signature help |
| `<leader>ca` | Normal | Code actions |
| `<leader>rn` | Normal | Rename symbol |
| `<leader>f` | Normal | Format document (async) |

## Completion (nvim-cmp)

**Note:** These keymaps are active in insert mode when the completion menu is visible.

| Key | Mode | Description |
|-----|------|-------------|
| `<C-Space>` | Insert | Trigger completion menu |
| `<C-e>` | Insert | Abort/close completion menu |
| `<CR>` | Insert | Confirm selection |
| `<Tab>` | Insert | Select next item / expand snippet / jump forward |
| `<S-Tab>` | Insert | Select previous item / jump backward in snippet |
| `<C-b>` | Insert | Scroll docs up |
| `<C-f>` | Insert | Scroll docs down |

## Treesitter (Incremental Selection)

| Key | Mode | Description |
|-----|------|-------------|
| `<CR>` | Normal | Initialize/expand selection |
| `<Tab>` | Visual | Expand scope |
| `<S-Tab>` | Visual | Shrink node |

## Which-key

| Key | Mode | Description |
|-----|------|-------------|
| `<leader>?` | Normal | Show buffer-local keymaps |
| `<leader>f` | Normal | [Group] Find operations |
| `<leader>c` | Normal | [Group] Code operations |
| `<leader>r` | Normal | [Group] Rename operations |

## Plugin-Specific Behavior

### Neo-tree Window Navigation
- Within Neo-tree, standard vim navigation (`j`, `k`, `h`, `l`) works
- `<CR>` opens files/directories
- `a` creates new files
- `d` deletes files
- `r` renames files
- `?` shows all Neo-tree keybindings

### Telescope Window Navigation
- `<C-n>` / `<C-p>` move down/up in results
- `<CR>` opens selected file
- `<C-x>` opens in horizontal split
- `<C-v>` opens in vertical split
- `<C-t>` opens in new tab
- `<Esc>` closes Telescope

## Tips

- Press `<leader>?` to see which-key hints for buffer-local keybindings
- In insert mode, `<C-Space>` triggers autocompletion
- Use `<leader>e` to see detailed diagnostic messages
- Most LSP functions work better with the cursor on a symbol
```

**Step 2: Verify markdown formatting**

Run:
```bash
cat nvim/keybindings.md | grep "^#" | head -5
```

Expected: Shows markdown headers properly formatted

**Step 3: Commit keybindings documentation**

Run:
```bash
git add nvim/keybindings.md
git commit -m "docs(nvim): add comprehensive keybindings reference

Document all keybindings for nvim config:
- General editor keymaps (window nav, movement, clipboard)
- Telescope fuzzy finder
- Neo-tree file explorer
- LSP buffer-local keymaps
- Completion engine shortcuts
- Which-key activation

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 11: Test and Verify Configuration

**Files:**
- Test: All nvim configuration

**Step 1: Stow the configuration**

Run:
```bash
cd /home/anirudh/.local/share/dotfiles
./install.sh
```

Expected: Configuration stowed successfully, symlinks created

**Step 2: Launch nvim and install plugins**

Run:
```bash
nvim
```

Expected:
1. Lazy.nvim opens automatically
2. Plugins begin installing
3. Wait for all plugins to install
4. Type `:q` to exit after installation completes

**Step 3: Verify LSP servers**

Run:
```bash
nvim --headless "+lua vim.lsp.enable('lua_ls')" "+LspInfo" "+qa" 2>&1 | grep -i lua_ls
```

Expected: Shows lua_ls is configured (may show "not attached" which is normal without a Lua file open)

**Step 4: Check for errors in log**

Run:
```bash
nvim --headless "+messages" "+qa" 2>&1 | grep -i error
```

Expected: No critical errors (warnings about missing files are okay)

**Step 5: Verify plugins loaded**

Run:
```bash
nvim --headless "+Lazy" "+qa" 2>&1 | grep -E "(tokyonight|telescope|neo-tree|treesitter|cmp|lspconfig|which-key)"
```

Expected: All 8 plugins listed

**Step 6: Test with a real file**

Create a test file and verify LSP works:
```bash
echo 'print("hello")' > /tmp/test.lua
nvim /tmp/test.lua
```

Manual verification:
1. Syntax highlighting works (colors visible)
2. Type `:LspInfo` - should show lua_ls attached
3. Move cursor to "print" and press `K` - hover docs appear
4. Press `<leader>?` - which-key shows available keymaps
5. Press `<C-n>` - Neo-tree toggles open/closed
6. Press `<leader>ff` - Telescope finds files
7. Type `:q!` to exit

**Step 7: Final commit**

Run:
```bash
git add -A
git commit -m "feat(nvim): complete minimal configuration cleanup

All plugins tested and verified working:
- Colorscheme: Tokyo Night applied
- Treesitter: Syntax highlighting active
- Telescope: Fuzzy finding operational
- Neo-tree: File explorer functional
- Completion: nvim-cmp with LSP integration
- LSP: All 6 language servers configured
- Which-key: Keymap hints working
- Documentation: Comprehensive keybindings.md

Verified with test file - all features operational.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Success Criteria Checklist

After completing all tasks, verify:

- [ ] All Lua diagnostics warnings resolved (no "undefined global vim")
- [ ] All 8 plugins have complete, non-empty configurations
- [ ] LSP working for all 6 languages (lua_ls, pyright, ts_ls, rust_analyzer, gopls, bashls)
- [ ] Telescope fuzzy finding operational (files and grep)
- [ ] Neo-tree file explorer functional
- [ ] Syntax highlighting active via Treesitter
- [ ] nvim-cmp completion working with Tab/S-Tab
- [ ] Which-key shows helpful hints
- [ ] All keybindings documented in keybindings.md
- [ ] Clean nvim startup with no errors
- [ ] Total config under 600 lines
- [ ] Old unused plugins removed
- [ ] Configuration follows modular structure
- [ ] Each commit is atomic and well-described

## Notes

- The configuration uses modern Neovim 0.10+ APIs (vim.lsp.config/enable)
- System LSP servers are used (no mason.nvim) - they must be installed via deps.yaml
- After first nvim launch, lazy.nvim will auto-install all plugins
- If a language server fails to attach, verify it's installed: `which lua-language-server`
- The keybindings.md file is in the module root for easy reference
