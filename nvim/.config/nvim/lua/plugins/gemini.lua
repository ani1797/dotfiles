-- Return two separate plugin specs
return {
  -- Optional which-key integration for AI group
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "AI" },
      },
    },
  },
  -- Dummy plugin spec for gemini CLI keybindings
  {
    "gemini-cli-keybindings",
    dir = vim.fn.stdpath("config"), -- Use config dir as dummy plugin location
    name = "gemini-cli-keybindings",
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
  },
}
