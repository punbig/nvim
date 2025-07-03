return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = true,
  },
  {
    "olimorris/onedarkpro.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("onedarkpro").setup({
        colors = {},
        highlights = {},
        styles = {
          comments = "italic",
          functions = "bold",
          keywords = "italic",
          strings = "NONE",
          variables = "NONE"
        },
        options = {
          bold = true,
          italic = true,
          underline = true,
          undercurl = true,
          cursorline = true,
          transparency = false,
          terminal_colors = true,
          window_unfocused_color = false,
        },
      })
      vim.cmd([[colorscheme onedark_vivid]])
    end,
  },
} 