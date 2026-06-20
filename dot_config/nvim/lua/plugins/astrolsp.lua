-- AstroLSP configuration — LSP servers, formatting, code actions
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- LSP formatting on save
    formatting = {
      format_on_save = {
        enabled = true,
        allow_filetypes = {
          "lua", "python", "rust", "go", "typescript", "javascript",
          "json", "yaml", "toml", "bash", "sh",
        },
      },
    },
    -- Server configuration overrides
    config = {
      -- Lua LSP: aware of Neovim globals
      lua_ls = {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      },
      -- Python: basedpyright
      basedpyright = {
        settings = {
          basedpyright = {
            analysis = { typeCheckingMode = "basic" },
          },
        },
      },
      -- Go: gopls
      gopls = {
        settings = {
          gopls = {
            gofumpt = true,
            analyses = { unusedparams = true },
            staticcheck = true,
          },
        },
      },
    },
  },
}
