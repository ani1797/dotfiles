-- AstroCore configuration — options, mappings, autocmds
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Editor options
    options = {
      opt = {
        relativenumber = true,
        number = true,
        signcolumn = "yes",
        wrap = false,
        tabstop = 2,
        shiftwidth = 2,
        softtabstop = 2,
        expandtab = true,
        scrolloff = 8,
        sidescrolloff = 8,
        cursorline = true,
        splitright = true,
        splitbelow = true,
        undofile = true,
        updatetime = 200,
        timeoutlen = 300,
      },
    },
    -- Custom mappings
    mappings = {
      n = {
        -- Buffer navigation
        ["<Leader>bn"] = { "<cmd>tabnew<cr>", desc = "New tab" },
        -- Quick save
        ["<C-s>"] = { "<cmd>w<cr>", desc = "Save file" },
        -- Clear search highlight
        ["<Esc>"] = { "<cmd>noh<cr>", desc = "Clear search highlight" },
        -- Better window navigation (already vim-style, this adds Ctrl)
        ["<C-h>"] = { "<C-w>h", desc = "Move to left window" },
        ["<C-j>"] = { "<C-w>j", desc = "Move to lower window" },
        ["<C-k>"] = { "<C-w>k", desc = "Move to upper window" },
        ["<C-l>"] = { "<C-w>l", desc = "Move to right window" },
        -- Resize windows
        ["<C-Up>"]    = { "<cmd>resize -2<cr>", desc = "Resize window up" },
        ["<C-Down>"]  = { "<cmd>resize +2<cr>", desc = "Resize window down" },
        ["<C-Left>"]  = { "<cmd>vertical resize -2<cr>", desc = "Resize window left" },
        ["<C-Right>"] = { "<cmd>vertical resize +2<cr>", desc = "Resize window right" },
        -- Oil.nvim file browser
        ["-"] = { "<cmd>Oil<cr>", desc = "Open Oil file browser" },
      },
      v = {
        -- Stay in indent mode
        ["<"] = { "<gv", desc = "Unindent line" },
        [">"] = { ">gv", desc = "Indent line" },
      },
      i = {
        ["<C-s>"] = { "<Esc><cmd>w<cr>", desc = "Save file" },
      },
    },
  },
}
