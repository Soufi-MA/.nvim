return {
	"CRAG666/betterTerm.nvim",
	lazy = false,
	opts = {
		display = "split",
		position = "bot",
		size = 15,
		startInserted = true,
		show_tabs = true,
		index_base = 0,
	},
	keys = {
		-- Toggle terminal (VSCode: Ctrl + `)
		{
			mode = { "n", "t" },
			"<C-`>",
			function()
				require("betterTerm").open()
			end,
			desc = "Toggle terminal",
		},

		-- New terminal (VSCode: Ctrl + Shift + `)
		{
			mode = { "n", "t" },
			"<C-S-`>",
			function()
				-- Find the next free index and open it (this creates a new terminal)
				local bt = require("betterTerm")
				local next_id = (vim.g.betterterm_next_id or 0) + 1
				vim.g.betterterm_next_id = next_id
				bt.open(next_id)
			end,
			desc = "New terminal",
		},

		-- Cycle terminals (VSCode-style)
		{
			mode = { "n", "t" },
			"<C-PageUp>",
			function()
				require("betterTerm").cycle(-1)
			end,
			desc = "Previous terminal",
		},
		{
			mode = { "n", "t" },
			"<C-PageDown>",
			function()
				require("betterTerm").cycle(1)
			end,
			desc = "Next terminal",
		},
	},
	config = function(_, opts)
		require("betterTerm").setup(opts)

		-- Esc → normal mode
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*",
			callback = function()
				vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = true, silent = true })
			end,
		})
	end,
}
