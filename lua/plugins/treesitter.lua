return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"help",
			"lua",
			"javascript",
			"typescript",
			"html",
			"jsx",
			"tsx",
		},
		highlight = { enable = true },
		indent = { enable = true },
	},
}
