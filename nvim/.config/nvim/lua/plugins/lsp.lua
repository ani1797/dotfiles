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
