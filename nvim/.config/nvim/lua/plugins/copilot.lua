return {
  "github/copilot.vim",
  config = function()
    -- Disable default Tab mapping (handled by nvim-cmp)
    vim.g.copilot_no_tab_map = true

    -- Disable for certain filetypes
    vim.g.copilot_filetypes = {
      ["*"] = true,
      gitcommit = false,
      markdown = true,
      yaml = true,
    }
  end,
}
