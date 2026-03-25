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
		{
			"<leader>pt",
			function()
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")
				local previewers = require("telescope.previewers")

				local terminals = {}
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					if vim.bo[buf].buftype == "terminal" then
						table.insert(terminals, buf)
					end
				end

				if #terminals == 0 then
					vim.notify("No terminal buffers found", vim.log.levels.WARN)
					return
				end

				pickers
					.new({}, {
						prompt_title = "Terminals",
						finder = finders.new_table({
							results = terminals,
							entry_maker = function(bufnr)
								local name = vim.api.nvim_buf_get_name(bufnr)
								if name == "" then
									name = "[Terminal " .. bufnr .. "]"
								else
									name = vim.fn.fnamemodify(name, ":t")
									if name:match("^term://") then
										name = "[Terminal] " .. name:gsub("^term://.*/", "")
									end
								end
								return {
									value = bufnr,
									display = name,
									ordinal = name,
									bufnr = bufnr,
								}
							end,
						}),
						sorter = conf.generic_sorter({}),
						previewer = previewers.new_buffer_previewer({
							title = "Terminal Preview",
							define_preview = function(self, entry)
								local bufnr = entry.value
								local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
								vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
							end,
						}),
						attach_mappings = function(prompt_bufnr, map)
							actions.select_default:replace(function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								if not selection then
									return
								end
								local selected_buf = selection.value

								local term_win = nil
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									local win_buf = vim.api.nvim_win_get_buf(win)
									if vim.bo[win_buf].buftype == "terminal" then
										term_win = win
										break
									end
								end

								if term_win then
									vim.api.nvim_win_set_buf(term_win, selected_buf)
									vim.api.nvim_set_current_win(term_win)
								else
									vim.cmd("botright 15split")
									vim.api.nvim_win_set_buf(0, selected_buf)
								end

								vim.g.main_term_buf = selected_buf
							end)
							return true
						end,
					})
					:find()
			end,
			desc = "Pick terminal",
		},
		{
			"<leader>pb",
			function()
				local pickers = require("telescope.pickers")
				local finders = require("telescope.finders")
				local conf = require("telescope.config").values
				local actions = require("telescope.actions")
				local action_state = require("telescope.actions.state")

				local buffers = {}
				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					local name = vim.api.nvim_buf_get_name(buf)
					if
						vim.api.nvim_buf_is_loaded(buf)
						and vim.bo[buf].buftype == ""
						and vim.bo[buf].filetype ~= "netrw"
						and name ~= ""
						and vim.fn.isdirectory(name) == 0
					then
						table.insert(buffers, buf)
					end
				end

				if #buffers == 0 then
					vim.notify("No file buffers found", vim.log.levels.WARN)
					return
				end

				pickers
					.new({}, {
						prompt_title = "Buffers (files only)",
						finder = finders.new_table({
							results = buffers,
							entry_maker = function(bufnr)
								local filename = vim.api.nvim_buf_get_name(bufnr)
								local name = vim.fn.fnamemodify(filename, ":t")
								return {
									value = bufnr,
									display = name,
									ordinal = name,
									bufnr = bufnr,
									filename = filename,
								}
							end,
						}),
						sorter = conf.generic_sorter({}),
						previewer = conf.file_previewer({}),
						attach_mappings = function(prompt_bufnr)
							actions.select_default:replace(function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								if selection then
									vim.cmd("buffer " .. selection.value)
								end
							end)
							return true
						end,
					})
					:find()
			end,
			desc = "Pick buffer",
		},
	},
}
