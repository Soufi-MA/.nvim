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

local term_height = nil
local term_prev_height = nil

local function is_bt_term(buf)
	return vim.bo[buf].buftype == "terminal" and vim.api.nvim_buf_get_name(buf):match("Term %(%d+%)$") ~= nil
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
				local height = is_bt_term(vim.api.nvim_get_current_buf()) and vim.api.nvim_win_get_height(0)
					or term_height

				local bt = require("betterTerm")
				local next_id = (vim.g.betterterm_next_id or 0) + 1
				vim.g.betterterm_next_id = next_id
				bt.open(next_id)

				if height then
					vim.api.nvim_win_set_height(0, height)
				end
			end,
			desc = "New terminal",
		},

		-- Cycle terminals (VSCode-style)
		{
			mode = { "n", "t" },
			"<C-h>",
			function()
				local height = is_bt_term(vim.api.nvim_get_current_buf()) and vim.api.nvim_win_get_height(0)
					or term_height
				require("betterTerm").cycle(-1)
				if height then
					vim.api.nvim_win_set_height(0, height)
				end
			end,
			desc = "Previous terminal",
		},
		{
			mode = { "n", "t" },
			"<C-l>",
			function()
				local height = is_bt_term(vim.api.nvim_get_current_buf()) and vim.api.nvim_win_get_height(0)
					or term_height
				require("betterTerm").cycle(1)
				if height then
					vim.api.nvim_win_set_height(0, height)
				end
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
		{ mode = { "n", "t" }, "<C-n>", toggle_maximize, desc = "Maximize terminal (toggle)" },
	},
	config = function(_, opts)
		require("betterTerm").setup(opts)

		-- Esc → normal mode
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*",
			callback = function()
				vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = true, silent = true })
			end,
		})

		-- Remember terminal height when its window closes
		vim.api.nvim_create_autocmd("WinClosed", {
			callback = function(args)
				local win = tonumber(args.match)
				if not win or not vim.api.nvim_win_is_valid(win) then
					return
				end
				local buf = vim.api.nvim_win_get_buf(win)
				if is_bt_term(buf) then
					term_height = vim.api.nvim_win_get_height(win)
					term_prev_height = vim.w[win].bt_prev_height
				end
			end,
		})

		-- Restore remembered height when a terminal window opens
		vim.api.nvim_create_autocmd("BufWinEnter", {
			callback = function(args)
				if not is_bt_term(args.buf) or not term_height then
					return
				end
				vim.schedule(function()
					local win = vim.fn.bufwinid(args.buf)
					if win ~= -1 and not vim.w[win].bt_prev_height then
						vim.api.nvim_win_set_height(win, term_height)
						vim.w[win].bt_prev_height = term_prev_height
					end
				end)
			end,
		})
	end,
}
