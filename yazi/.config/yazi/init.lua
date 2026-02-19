-- Yazi Plugin Initialization
-- Plugins are installed via: configure-yazi

-- Git status integration for file list
-- Requires: yazi-rs/plugins:git (install via configure-yazi)
local ok, git = pcall(require, "git")
if ok then git:setup() end
