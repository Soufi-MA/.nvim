local function toggle_maximize()
	local win = vim.api.nvim_get_current_win()
	if vim.w[win].bt_prev_height then
		vim.api.nvim_win_set_height(win, vim.w[win].bt_prev_height)
		vim.w[win].bt_prev_height = nil
	else
		vim.w[win].bt_prev_height = vim.api.nvim_win_get_height(win)
		vim.cmd("resize")
	end
end

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
				require("betterTerm").toggle_termwindow()
			end,
			desc = "Toggle terminal",
		},

		-- New terminal (VSCode: Ctrl + Shift + `)
		{
			mode = { "n", "t" },
			"<C-S-~>",
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
			"<C-h>",
			function()
				require("betterTerm").cycle(-1)
			end,
			desc = "Previous terminal",
		},
		{
			mode = { "n", "t" },
			"<C-l>",
			function()
				require("betterTerm").cycle(1)
			end,
			desc = "Next terminal",
		},

		-- Resize terminal / toggle fullscreen
		{
			mode = { "n", "t" },
			"<C-k>",
			function()
				vim.cmd("resize +3")
			end,
			desc = "Increase terminal height",
		},
		{
			mode = { "n", "t" },
			"<C-j>",
			function()
				vim.cmd("resize -3")
			end,
			desc = "Decrease terminal height",
		},
		{ mode = { "n", "t" }, "<A-m>", toggle_maximize, desc = "Maximize terminal (toggle)" },
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
