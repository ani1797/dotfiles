-- Polish — final customisations: autocmds, filetype overrides, etc.
return function()
  -- Highlight yanked text
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
  })

  -- Close certain buffers with q
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "help", "lspinfo", "man", "notify", "qf", "checkhealth" },
    callback = function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
  })

  -- Auto-resize panes on terminal resize
  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      vim.cmd("tabdo wincmd =")
    end,
  })

  -- Wrap and spell check for text files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
      vim.opt_local.wrap = true
      vim.opt_local.spell = true
    end,
  })
end
