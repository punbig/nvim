-- Disable netrw for nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load core configurations
require("config.options")  -- Load options
require("config.keymaps") -- Load keymaps

-- Initialize lazy.nvim
require("lazy").setup({
  spec = {
    { import = "plugins" },
  },
  defaults = {
    lazy = true,        -- All plugins are lazy-loaded by default
    version = "*",      -- Try to use the latest stable versions of plugins
  },
  install = {
    colorscheme = { "onedark" },
  },
  checker = {
    enabled = true,     -- Automatically check for plugin updates
    notify = false,     -- Don't show update notifications
  },
  change_detection = {
    notify = false,     -- Don't show notification when config changes
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
