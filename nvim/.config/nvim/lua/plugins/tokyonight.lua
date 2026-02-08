return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function(plug, opts)
    vim.cmd([[colorscheme tokyonight-night]])
  end
}
