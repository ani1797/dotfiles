# Vim/Neovim Simplification Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Simplify vim/nvim configs by removing mason.nvim, creating parallel vim/nvim setups with shared system-installed LSP servers, and integrating GitHub Copilot + Gemini CLI.

**Architecture:** Remove mason.nvim from nvim, rewrite LSP config to use system-installed servers, build parallel vim config with vim-plug + coc.nvim achieving same features, add AI integrations (Copilot + Gemini) to both.

**Tech Stack:** Neovim + lazy.nvim, Vim + vim-plug + coc.nvim, system LSP servers, GitHub Copilot, Gemini CLI

---

## Task 1: Backup and Remove Avante Plugin

**Files:**
- Delete: `nvim/.config/nvim/lua/plugins/avante.lua`

**Step 1: Check if avante plugin exists**

Run: `ls -la nvim/.config/nvim/lua/plugins/avante.lua`
Expected: File exists or "No such file or directory"

**Step 2: Remove avante plugin config**

Run: `rm -f nvim/.config/nvim/lua/plugins/avante.lua`

**Step 3: Commit**

```bash
git add -A
git commit -m "refactor(nvim): remove avante plugin

Replace avante with GitHub Copilot + Gemini CLI integration.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Update nvim Dependencies

**Files:**
- Modify: `nvim/deps.yaml`

**Step 1: Read current deps.yaml**

Run: `cat nvim/deps.yaml`
Expected: Current dependency list

**Step 2: Update deps.yaml with LSP servers**

Replace content with:

```yaml
# nvim module dependencies
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
  - run: "command -v gemini || echo 'Gemini CLI not installed. Install from https://ai.google.dev/gemini-api/docs/cli'"
    provides: gemini
```

**Step 3: Commit**

```bash
git add nvim/deps.yaml
git commit -m "feat(nvim): add LSP servers to system dependencies

Move LSP server installation from mason to system packages.
Add Gemini CLI check script.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Rewrite nvim LSP Config (Remove Mason)

**Files:**
- Modify: `nvim/.config/nvim/lua/plugins/lsp.lua`

**Step 1: Read current lsp.lua**

Run: `cat nvim/.config/nvim/lua/plugins/lsp.lua`
Expected: Current mason-based config

**Step 2: Rewrite lsp.lua without mason**

Replace entire file content with:

```lua
return {
  {
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

      local lspconfig = require("lspconfig")

      -- Lua
      lspconfig.lua_ls.setup({
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

      -- Python
      lspconfig.pyright.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- TypeScript/JavaScript
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Rust
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Go
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Bash
      lspconfig.bashls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })
    end,
  },
}
```

**Step 3: Verify syntax**

Run: `nvim --headless -c "luafile nvim/.config/nvim/lua/plugins/lsp.lua" -c "quit" 2>&1 | head -20`
Expected: No Lua syntax errors (or just warnings about missing modules, which is fine)

**Step 4: Commit**

```bash
git add nvim/.config/nvim/lua/plugins/lsp.lua
git commit -m "refactor(nvim): remove mason, use system LSP servers

Replace mason.nvim with direct lspconfig setup.
LSP servers now installed via system packages.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Add GitHub Copilot Plugin to nvim

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/copilot.lua`

**Step 1: Create copilot.lua**

```lua
return {
  "github/copilot.vim",
  config = function()
    -- Accept suggestion with Tab
    vim.g.copilot_no_tab_map = true
    vim.keymap.set("i", "<Tab>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })

    -- Disable for certain filetypes
    vim.g.copilot_filetypes = {
      ["*"] = true,
      gitcommit = false,
      markdown = true,
      yaml = true,
    }
  end,
}
```

**Step 2: Verify syntax**

Run: `nvim --headless -c "luafile nvim/.config/nvim/lua/plugins/copilot.lua" -c "quit"`
Expected: No errors

**Step 3: Commit**

```bash
git add nvim/.config/nvim/lua/plugins/copilot.lua
git commit -m "feat(nvim): add GitHub Copilot integration

Add copilot.vim plugin with Tab completion binding.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Add Gemini CLI Integration to nvim

**Files:**
- Create: `nvim/.config/nvim/lua/plugins/gemini.lua`

**Step 1: Create gemini.lua**

```lua
return {
  -- No plugin required, just keybindings for gemini CLI
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "AI" },
      },
    },
  },
  config = function()
    -- Send visual selection to gemini and insert response
    vim.keymap.set("v", "<leader>ai", function()
      -- Get visual selection
      vim.cmd('noau normal! "vy"')
      local selection = vim.fn.getreg("v")

      -- Check if gemini is available
      local has_gemini = vim.fn.executable("gemini") == 1
      if not has_gemini then
        vim.notify("Gemini CLI not found. Install from https://ai.google.dev/gemini-api/docs/cli", vim.log.levels.ERROR)
        return
      end

      -- Call gemini CLI
      local escaped = selection:gsub("'", "'\\''")
      local cmd = "gemini ask '" .. escaped .. "'"
      local result = vim.fn.system(cmd)

      if vim.v.shell_error ~= 0 then
        vim.notify("Gemini CLI error: " .. result, vim.log.levels.ERROR)
        return
      end

      -- Insert result below selection
      vim.cmd('normal! `>o')
      vim.api.nvim_put(vim.split(result, "\n"), "l", true, true)
    end, { desc = "Ask Gemini AI" })

    -- Send current buffer to gemini for explanation
    vim.keymap.set("n", "<leader>ae", function()
      local has_gemini = vim.fn.executable("gemini") == 1
      if not has_gemini then
        vim.notify("Gemini CLI not found. Install from https://ai.google.dev/gemini-api/docs/cli", vim.log.levels.ERROR)
        return
      end

      -- Get buffer content
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      local content = table.concat(lines, "\n")
      local escaped = content:gsub("'", "'\\''")

      -- Ask gemini to explain
      local cmd = "gemini ask 'Explain this code: " .. escaped .. "'"
      local result = vim.fn.system(cmd)

      if vim.v.shell_error ~= 0 then
        vim.notify("Gemini CLI error: " .. result, vim.log.levels.ERROR)
        return
      end

      -- Show in floating window
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))
      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.8)
      local opts = {
        relative = "editor",
        width = width,
        height = height,
        col = math.floor((vim.o.columns - width) / 2),
        row = math.floor((vim.o.lines - height) / 2),
        style = "minimal",
        border = "rounded",
      }
      vim.api.nvim_open_win(buf, true, opts)
    end, { desc = "Explain with Gemini" })
  end,
}
```

**Step 2: Verify syntax**

Run: `nvim --headless -c "luafile nvim/.config/nvim/lua/plugins/gemini.lua" -c "quit"`
Expected: No errors

**Step 3: Commit**

```bash
git add nvim/.config/nvim/lua/plugins/gemini.lua
git commit -m "feat(nvim): add Gemini CLI integration

Add keybindings for Gemini AI:
- <leader>ai: Ask Gemini about visual selection
- <leader>ae: Explain current buffer with Gemini

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Create Vim Directory Structure

**Files:**
- Create: `vim/.vim/autoload/`
- Create: `vim/.vim/plugin/`

**Step 1: Create directory structure**

Run: `mkdir -p vim/.vim/autoload vim/.vim/plugin`

**Step 2: Download vim-plug**

Run: `curl -fLo vim/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`
Expected: Download successful

**Step 3: Verify vim-plug downloaded**

Run: `ls -la vim/.vim/autoload/plug.vim`
Expected: File exists

**Step 4: Commit**

```bash
git add vim/.vim/autoload/plug.vim
git commit -m "feat(vim): add vim-plug package manager

Bootstrap vim-plug for plugin management.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Create Vim Dependencies

**Files:**
- Create: `vim/deps.yaml`

**Step 1: Create deps.yaml**

```yaml
# vim module dependencies
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
    - vim
    - nodejs
    - npm
    - ripgrep
    - fd-find
    - lua-language-server
    - pyright
  macos:
    - vim
    - node
    - npm
    - ripgrep
    - fd
    - lua-language-server
    - pyright
    - typescript-language-server
    - rust-analyzer
    - gopls
    - bash-language-server

script:
  - run: "command -v gemini || echo 'Gemini CLI not installed. Install from https://ai.google.dev/gemini-api/docs/cli'"
    provides: gemini
```

**Step 2: Commit**

```bash
git add vim/deps.yaml
git commit -m "feat(vim): add system dependencies

Add vim, nodejs, LSP servers, and Gemini CLI check.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: Create Vim Main Config

**Files:**
- Create: `vim/.vimrc`

**Step 1: Create .vimrc**

```vim
" ~/.vimrc
" vim:foldmethod=marker:foldlevel=0

" Basic Settings {{{
set number
set relativenumber
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent
set hidden
set updatetime=300
set signcolumn=yes
set nobackup
set nowritebackup
set cmdheight=2
set shortmess+=c
syntax on
filetype plugin indent on

" Leader key
let mapleader = " "
let maplocalleader = "\\"
" }}}

" vim-plug Plugins {{{
call plug#begin('~/.vim/plugged')

" LSP and Completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" File Navigation
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree'

" Theme
Plug 'folke/tokyonight.nvim'

" Keybinding Hints
Plug 'liuchengxu/vim-which-key'

" AI Integration
Plug 'github/copilot.vim'

call plug#end()
" }}}

" Theme {{{
if has('termguicolors')
  set termguicolors
endif
colorscheme tokyonight-night
" }}}

" Plugin Configs {{{
" Load plugin-specific configs
runtime! plugin/*.vim
" }}}
```

**Step 2: Verify syntax**

Run: `vim -u vim/.vimrc -c "quit" 2>&1 | grep -i error || echo "No errors"`
Expected: "No errors" or warnings about missing plugins (which is fine)

**Step 3: Commit**

```bash
git add vim/.vimrc
git commit -m "feat(vim): add main vimrc configuration

Basic settings, vim-plug setup, and plugin declarations.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 9: Create Vim LSP Config (coc.nvim)

**Files:**
- Create: `vim/.vim/plugin/lsp.vim`
- Create: `vim/.vim/coc-settings.json`

**Step 1: Create lsp.vim**

```vim
" LSP keybindings for coc.nvim

" Use Tab for trigger completion
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Code action on current line
nmap <leader>ca  <Plug>(coc-codeaction-cursor)

" Highlight the symbol and its references when holding cursor
autocmd CursorHold * silent call CocActionAsync('highlight')
```

**Step 2: Create coc-settings.json**

```json
{
  "languageserver": {
    "lua": {
      "command": "lua-language-server",
      "filetypes": ["lua"],
      "rootPatterns": [".git/"]
    },
    "bash": {
      "command": "bash-language-server",
      "args": ["start"],
      "filetypes": ["sh", "bash"],
      "ignoredRootPaths": ["~"]
    }
  },
  "pyright.enable": true,
  "tsserver.enable": true,
  "rust-analyzer.enable": true,
  "go.goplsPath": "gopls",
  "diagnostic.errorSign": "✘",
  "diagnostic.warningSign": "⚠",
  "diagnostic.infoSign": "ℹ",
  "diagnostic.hintSign": "➤",
  "suggest.noselect": false,
  "coc.preferences.formatOnSaveFiletypes": [
    "python",
    "javascript",
    "typescript",
    "rust",
    "go"
  ]
}
```

**Step 3: Commit**

```bash
git add vim/.vim/plugin/lsp.vim vim/.vim/coc-settings.json
git commit -m "feat(vim): add coc.nvim LSP configuration

LSP keybindings and language server settings.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 10: Create Vim File Navigation Configs

**Files:**
- Create: `vim/.vim/plugin/fzf.vim`
- Create: `vim/.vim/plugin/nerdtree.vim`

**Step 1: Create fzf.vim**

```vim
" FZF fuzzy finder configuration

" Keybindings
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :Rg<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fh :History<CR>

" FZF layout
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }

" Preview window
let g:fzf_preview_window = ['right:50%', 'ctrl-/']

" Customize fzf colors to match tokyonight
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
```

**Step 2: Create nerdtree.vim**

```vim
" NERDTree file explorer configuration

" Toggle NERDTree
nnoremap <leader>e :NERDTreeToggle<CR>

" Find current file in NERDTree
nnoremap <leader>ef :NERDTreeFind<CR>

" NERDTree settings
let NERDTreeShowHidden=1
let NERDTreeIgnore=['\.git$', '\.DS_Store$', '__pycache__', '\.pyc$']
let NERDTreeMinimalUI=1
let NERDTreeDirArrows=1

" Close vim if NERDTree is the only window remaining
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif
```

**Step 3: Commit**

```bash
git add vim/.vim/plugin/fzf.vim vim/.vim/plugin/nerdtree.vim
git commit -m "feat(vim): add file navigation configs

FZF fuzzy finder and NERDTree file explorer.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 11: Create Vim AI Integration Configs

**Files:**
- Create: `vim/.vim/plugin/copilot.vim`
- Create: `vim/.vim/plugin/gemini.vim`

**Step 1: Create copilot.vim**

```vim
" GitHub Copilot configuration

" Copilot is enabled by default
" Accept suggestion with Tab (if copilot has suggestion, otherwise normal tab)
imap <silent><script><expr> <Tab> copilot#Accept("\<Tab>")
let g:copilot_no_tab_map = v:true

" Disable for certain filetypes
let g:copilot_filetypes = {
      \ 'gitcommit': v:false,
      \ 'markdown': v:true,
      \ 'yaml': v:true,
      \ }

" Copilot commands (shown in which-key)
" :Copilot setup - Initial GitHub authentication
" :Copilot enable/disable - Toggle on/off
" :Copilot panel - Open suggestions panel
```

**Step 2: Create gemini.vim**

```vim
" Gemini CLI integration

" Ask Gemini about visual selection
vnoremap <leader>ai :call AskGemini()<CR>

" Explain current buffer with Gemini
nnoremap <leader>ae :call ExplainWithGemini()<CR>

function! AskGemini() range
  " Check if gemini is available
  if !executable('gemini')
    echohl ErrorMsg
    echo "Gemini CLI not found. Install from https://ai.google.dev/gemini-api/docs/cli"
    echohl None
    return
  endif

  " Get visual selection
  let l:lines = getline(a:firstline, a:lastline)
  let l:selection = join(l:lines, "\n")

  " Escape single quotes for shell
  let l:escaped = substitute(l:selection, "'", "'\\\\''", 'g')

  " Call gemini CLI
  let l:cmd = "gemini ask '" . l:escaped . "'"
  let l:result = system(l:cmd)

  if v:shell_error != 0
    echohl ErrorMsg
    echo "Gemini CLI error: " . l:result
    echohl None
    return
  endif

  " Insert result below selection
  call append(a:lastline, split(l:result, "\n"))
endfunction

function! ExplainWithGemini()
  " Check if gemini is available
  if !executable('gemini')
    echohl ErrorMsg
    echo "Gemini CLI not found. Install from https://ai.google.dev/gemini-api/docs/cli"
    echohl None
    return
  endif

  " Get buffer content
  let l:lines = getline(1, '$')
  let l:content = join(l:lines, "\n")
  let l:escaped = substitute(l:content, "'", "'\\\\''", 'g')

  " Ask gemini to explain
  let l:cmd = "gemini ask 'Explain this code: " . l:escaped . "'"
  let l:result = system(l:cmd)

  if v:shell_error != 0
    echohl ErrorMsg
    echo "Gemini CLI error: " . l:result
    echohl None
    return
  endif

  " Open result in new split
  new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(l:result, "\n"))
endfunction
```

**Step 3: Commit**

```bash
git add vim/.vim/plugin/copilot.vim vim/.vim/plugin/gemini.vim
git commit -m "feat(vim): add AI integration configs

GitHub Copilot and Gemini CLI keybindings.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 12: Create Vim Which-Key Config

**Files:**
- Create: `vim/.vim/plugin/whichkey.vim`

**Step 1: Create whichkey.vim**

```vim
" vim-which-key configuration

" Enable which-key on leader key
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey '\'<CR>

" Define leader key mappings
let g:which_key_map = {}

" File operations
let g:which_key_map.f = {
      \ 'name' : '+find',
      \ 'f' : 'files',
      \ 'g' : 'grep',
      \ 'b' : 'buffers',
      \ 'h' : 'history',
      \ }

" Explorer
let g:which_key_map.e = {
      \ 'name' : '+explorer',
      \ '' : 'toggle',
      \ 'f' : 'find-current',
      \ }

" AI
let g:which_key_map.a = {
      \ 'name' : '+ai',
      \ 'i' : 'ask-gemini',
      \ 'e' : 'explain',
      \ }

" Code
let g:which_key_map.c = {
      \ 'name' : '+code',
      \ 'a' : 'action',
      \ }

" Rename
let g:which_key_map.r = {
      \ 'name' : '+refactor',
      \ 'n' : 'rename',
      \ }

" Register which-key map
call which_key#register('<Space>', "g:which_key_map")

" Show which-key popup on leader key
set timeoutlen=500
```

**Step 2: Commit**

```bash
git add vim/.vim/plugin/whichkey.vim
git commit -m "feat(vim): add which-key configuration

Keybinding hints for leader key mappings.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 13: Add .stow-local-ignore for Vim

**Files:**
- Create: `vim/.stow-local-ignore`

**Step 1: Create .stow-local-ignore**

```
^/deps\.yaml$
^/\.stow-local-ignore$
```

**Step 2: Commit**

```bash
git add vim/.stow-local-ignore
git commit -m "feat(vim): add stow ignore file

Prevent deps.yaml and .stow-local-ignore from being symlinked.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 14: Test Neovim Setup

**Files:**
- Test: Neovim configuration

**Step 1: Install system dependencies (optional if not installed yet)**

Run: `./install.sh`
Expected: Installs LSP servers and stows configs (may take a few minutes)

**Step 2: Open neovim and check for errors**

Run: `nvim --headless "+Lazy! sync" +qa`
Expected: lazy.nvim installs/updates plugins (first run may take time)

**Step 3: Open neovim interactively**

Run: `nvim`
Expected: No errors, TokyoNight theme loads

**Step 4: Check LSP servers available**

In nvim, run: `:LspInfo`
Expected: Shows configured LSP servers (lua_ls, pyright, etc.)

**Step 5: Test a file with LSP**

```bash
echo 'print("hello")' > /tmp/test.py
nvim /tmp/test.py
```

In nvim:
- Type and check for completion suggestions
- Hover over `print` and press `K` - should show documentation
- No errors in bottom line

**Step 6: Check Copilot status**

In nvim, run: `:Copilot status`
Expected: Shows status (may need `:Copilot setup` for first-time auth)

**Step 7: Document results**

Run: `echo "nvim setup: [PASS/FAIL]" >> docs/plans/2026-02-21-test-results.txt`

---

## Task 15: Test Vim Setup

**Files:**
- Test: Vim configuration

**Step 1: Open vim and install plugins**

Run: `vim -c PlugInstall`
Expected: vim-plug installs all plugins, then press 'D' to view diffs and verify

**Step 2: Install coc extensions**

In vim, run: `:CocInstall coc-pyright coc-tsserver coc-rust-analyzer`
Expected: Coc installs LSP extensions (may take a minute)

**Step 3: Open vim interactively**

Run: `vim`
Expected: No errors, TokyoNight theme loads

**Step 4: Check coc status**

In vim, run: `:CocInfo`
Expected: Shows coc status and installed extensions

**Step 5: Test a file with LSP**

```bash
echo 'print("hello")' > /tmp/test2.py
vim /tmp/test2.py
```

In vim:
- Type and wait for completion popup
- Hover over `print` and press `K` - should show documentation
- No errors

**Step 6: Test file navigation**

In vim:
- Press `<Space>ff` - should open FZF file finder
- Press `<Space>e` - should toggle NERDTree
- Verify both work

**Step 7: Check Copilot status**

In vim, run: `:Copilot status`
Expected: Shows status (may need `:Copilot setup` for first-time auth)

**Step 8: Document results**

Run: `echo "vim setup: [PASS/FAIL]" >> docs/plans/2026-02-21-test-results.txt`

---

## Task 16: Update CLAUDE.md with Implementation Notes

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Add implementation notes to CLAUDE.md**

Add to the end of the "Module directories" section:

```markdown
  - **vim/nvim package management**:
    - nvim uses lazy.nvim (Lua-based plugin manager)
    - vim uses vim-plug (VimScript plugin manager)
    - Both use coc.nvim (vim) or nvim-lspconfig (nvim) for LSP
    - LSP servers installed via system packages (see deps.yaml)
    - No mason.nvim - simpler architecture
    - Both configs provide VSCode-like features: autocomplete, go-to-definition, file navigation
    - AI integration: GitHub Copilot (inline) + Gemini CLI (command-based)
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with vim/nvim implementation notes

Document simplified package management approach.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 17: Final Verification and Cleanup

**Files:**
- Verify: All changes committed

**Step 1: Check git status**

Run: `git status`
Expected: Clean working directory (nothing uncommitted)

**Step 2: Review test results**

Run: `cat docs/plans/2026-02-21-test-results.txt`
Expected: Both vim and nvim tests passed

**Step 3: Optional: Clean up mason data**

Run: `rm -rf ~/.local/share/nvim/mason`
Expected: Old mason directory removed (LSP servers now in system paths)

**Step 4: Create final summary commit**

```bash
git commit --allow-empty -m "feat: complete vim/nvim simplification

Summary of changes:
- Removed mason.nvim from nvim
- Rewrote nvim LSP config to use system packages
- Created parallel vim config with same features
- Added GitHub Copilot + Gemini CLI to both
- Both configs use single package manager each
- Faster startup, easier troubleshooting

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Post-Implementation

### User Actions Required

1. **Run installation:**
   ```bash
   ./install.sh
   ```

2. **First time nvim launch:**
   - Plugins auto-install on first launch
   - Wait for lazy.nvim to complete
   - Restart nvim

3. **First time vim launch:**
   - Run `:PlugInstall` to install plugins
   - Run `:CocInstall coc-pyright coc-tsserver coc-rust-analyzer` for LSP extensions
   - Restart vim

4. **GitHub Copilot setup:**
   - In nvim: `:Copilot setup`
   - In vim: `:Copilot setup`
   - Authenticate with GitHub (one-time)

5. **Optional: Gemini CLI:**
   - Install from https://ai.google.dev/gemini-api/docs/cli
   - Authenticate with Google Cloud
   - Test with `gemini ask "Hello"`

### Verification Checklist

- [ ] `./install.sh` runs without errors
- [ ] nvim opens without errors
- [ ] vim opens without errors
- [ ] LSP works in nvim (gd, K, autocomplete)
- [ ] LSP works in vim (gd, K, autocomplete)
- [ ] File navigation works (Telescope/FZF, NeoTree/NERDTree)
- [ ] Copilot works in both editors
- [ ] Gemini keybindings work (if CLI installed)
- [ ] Both use same system LSP servers
- [ ] Startup is noticeably faster

### Success Metrics

- **Simplicity:** One package manager per editor (lazy.nvim or vim-plug)
- **Speed:** Faster nvim startup (no mason checks)
- **Maintainability:** LSP servers managed via deps.yaml
- **Features:** Both editors provide VSCode-like experience
- **Consistency:** Same LSP servers, same AI tools

### Troubleshooting

**LSP not working:**
- Verify LSP server installed: `which lua-language-server`
- Check nvim: `:LspInfo`
- Check vim: `:CocInfo`

**Plugins not loading:**
- nvim: `:Lazy sync`
- vim: `:PlugUpdate`

**Copilot not working:**
- Run `:Copilot setup`
- Check `:Copilot status`
- Authenticate with GitHub

**Gemini not working:**
- Verify: `which gemini`
- Test: `gemini ask "test"`
- Install if missing

---

## Related Skills

When implementing this plan, consider using:
- @superpowers:executing-plans for task-by-task execution
- @superpowers:verification-before-completion before claiming tasks complete
- @superpowers:systematic-debugging if issues arise during implementation

---

**Implementation approach:** Use @superpowers:executing-plans or @superpowers:subagent-driven-development to execute tasks sequentially with verification steps.
