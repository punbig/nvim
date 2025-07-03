return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
  },
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme onedark]])
    end,
  },
} 