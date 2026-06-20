-- User plugins — extend AstroNvim with additional plugins
return {
  -- Oil.nvim: edit the filesystem like a buffer
  {
    "stevearc/oil.nvim",
    lazy = false,
    opts = {
      default_file_explorer = true,
      columns = {
        "icon",
        "permissions",
        "size",
      },
      view_options = {
        show_hidden = true,
      },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  -- Mini.surround: add/delete/replace surroundings
  {
    "echasnovski/mini.surround",
    opts = {
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    },
  },
  -- Catppuccin: explicit setup for full integration
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = false,
      show_end_of_buffer = false,
      integrations = {
        treesitter = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
        },
        telescope = { enabled = true },
        which_key = true,
        mason = true,
        gitsigns = true,
        nvimtree = false,
        neo_tree = true,
        cmp = true,
        dap = true,
        dap_ui = true,
      },
    },
  },
}
