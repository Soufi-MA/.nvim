return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	keys = {
		{
			"<leader>pf",
			"<cmd>Telescope find_files<cr>",
			desc = "Lists files in your current working directory, respects .gitignore",
		},
		{
			"<C-p>",
			"<cmd>Telescope git_files<cr>",
			desc = "Fuzzy search through the output of git ls-files command, respects .gitignore",
		},
		{
			"<leader>pg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Searches for the string under your cursor or selection in your current working directory",
		},
	},
}
