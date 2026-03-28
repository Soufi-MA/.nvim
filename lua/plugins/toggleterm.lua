return {
	"akinsho/toggleterm.nvim",
	version = "*",
	lazy = true,
	keys = {
		{ "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal (last used)" },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle floating terminal" },
		{ "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle horizontal terminal" },
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Toggle vertical terminal" },
		{ "<leader>ts", "<cmd>ToggleTermSendVisualSelection<cr>", mode = "v", desc = "Send selection to terminal" },
		{ "<leader>ts", "<cmd>ToggleTermSendCurrentLine<cr>", desc = "Send line to terminal" },
		{
			"<leader>tn",
			function()
				local Terminal = require("toggleterm.terminal").Terminal
				local new_term = Terminal:new()
				new_term:toggle()
			end,
			desc = "New terminal",
		},
		{
			"<leader>pt",
			function()
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")

				local terminal_bufs = vim.tbl_filter(function(bufnr)
					return vim.bo[bufnr].buftype == "terminal"
				end, vim.api.nvim_list_bufs())

				if #terminal_bufs == 0 then
					vim.notify("No terminals found", vim.log.levels.INFO)
					return
				end

				pickers
					.new({}, {
						prompt_title = "Toggleterm Terminals",
						finder = finders.new_table({
							results = terminal_bufs,
							entry_maker = function(bufnr)
								local name = vim.api.nvim_buf_get_name(bufnr)
								local id_str = name:match("toggleterm#(%d+)") or name:match("#(%d+)")
								local id = id_str and tonumber(id_str) or bufnr

								return {
									value = { bufnr = bufnr, id = id },
									display = string.format("Terminal %d  (buf %d)", id, bufnr),
									ordinal = tostring(id),
								}
							end,
						}),
						sorter = conf.generic_sorter({}),
						attach_mappings = function(prompt_bufnr)
							actions.select_default:replace(function()
								actions.close(prompt_bufnr)
								local selection = action_state.get_selected_entry()
								if selection and selection.value then
									local id = selection.value.id
									if type(id) == "number" and id > 0 then
										vim.cmd(id .. "ToggleTerm")
									else
										vim.api.nvim_set_current_buf(selection.value.bufnr)
										vim.cmd("startinsert")
									end
								end
							end)
							return true
						end,
					})
					:find()
			end,
			desc = "Telescope: select toggleterm terminal",
		},
	},
	opts = {
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4
			end
		end,
		open_mapping = [[<C-\>]],
		hide_numbers = true,
		shade_terminals = true,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = true,
		terminal_mappings = true,
		persist_size = true,
		persist_mode = true,
		direction = "float",
		close_on_exit = true,
		shell = vim.o.shell,
		float_opts = {
			border = "curved",
			winblend = 0,
			highlights = { border = "Normal", background = "Normal" },
		},
		winbar = {
			enabled = false,
		},
	},
	init = function()
		vim.api.nvim_create_autocmd("TermOpen", {
			pattern = "term://*",
			callback = function()
				vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = true, silent = true })
			end,
		})
	end,
}
