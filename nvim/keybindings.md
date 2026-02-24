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
