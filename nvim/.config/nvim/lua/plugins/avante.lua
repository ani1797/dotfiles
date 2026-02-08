-- Delete this file to disable AI features
return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  version = false,
  opts = {
    provider = "claude",
    providers = {
      claude = {
        model = "claude-sonnet-4-20250514",
        extra_request_body = {
          max_tokens = 4096,
        },
      },
    },
    behaviour = {
      auto_suggestions = false,
      auto_apply_diff_after_generation = false,
    },
    mappings = {
      ask = "<leader>aa",
      edit = "<leader>ae",
      refresh = "<leader>ar",
    },
  },
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
}
