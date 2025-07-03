return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		version = false,
		dependencies = {
		  "nvim-lua/plenary.nvim",
		  {
		    "nvim-telescope/telescope-fzf-native.nvim",
		    build = "make",
		  },
		},
		keys = {
		  { "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
		  { "<C-p>", "<cmd>Telescope git_files<cr>", desc = "Git Files" },
		  { "<leader>ps", function()
		    require('telescope.builtin').grep_string({ search = vim.fn.input("Grep > ")})
		  end, desc = "Grep String" },
		},
		opts = {
		  defaults = {
		    mappings = {
		      i = {
			["<C-u>"] = false,
			["<C-d>"] = false,
		      },
		    },
		  },
		},
	      },
}