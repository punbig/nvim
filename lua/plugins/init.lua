return {
	{"ellisonleao/gruvbox.nvim", priority = 1000, config = true},
	"folke/neodev.nvim",
	"folke/which-key.nvim",
	"nvim-lua/plenary.nvim",
	"ThePrimeagen/harpoon",
	{ "folke/neoconf.nvim", cmd = "Neoconf" },
	{ 
		"olimorris/onedarkpro.nvim",
		lazy = false,
		priority = 1000,
		config = function ()
			vim.cmd([[colorscheme onedark]])
		end,
	},
}
