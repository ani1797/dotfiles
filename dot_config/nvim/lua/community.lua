-- AstroCommunity plugin imports
-- Docs: https://github.com/AstroNvim/astrocommunity
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.typescript-all-in-one" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.toml" },
  -- Colorscheme
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- Editor enhancements
  { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.editing-support.nvim-treesitter-context" },
  { import = "astrocommunity.git.diffview-nvim" },
  { import = "astrocommunity.fuzzy-finder.fzf-lua" },
}
