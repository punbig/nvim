return {
  {
    "folke/neodev.nvim",
    opts = {},
    ft = { "lua" },
  },
  {
    "folke/neoconf.nvim",
    cmd = "Neoconf",
    config = true,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("config.treesitter")
    end,
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter-textobjects",
        init = function()
          -- disable rtp plugin, as we only need its queries for mini.ai
          -- In case you want to use the plugin, comment this line
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
        end,
      },
    },
  },
} 