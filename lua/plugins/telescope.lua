return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},

	keys = {
		{ "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
		{ "<C-p>", "<cmd>Telescope git_files<cr>", desc = "Git files" },
		{
			"<leader>pg",
			function()
				require("telescope.builtin").live_grep()
			end,
			desc = "Live grep",
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
								local term_title = vim.fn.getbufvar(bufnr, "term_title") or "terminal"

								local display = string.format("[%d] %s", bufnr, term_title)

								local ok, cwd = pcall(vim.api.nvim_buf_call, bufnr, function()
									return vim.fn.getcwd()
								end)
								if ok and cwd and cwd ~= "" then
									local cwd_name = vim.fn.fnamemodify(cwd, ":t")
									if cwd_name ~= "" and cwd_name ~= "." then
										display = display .. " (" .. cwd_name .. ")"
									end
								end

								return {
									value = bufnr,
									display = display,
									ordinal = display .. " " .. term_title, -- better fuzzy search
									bufnr = bufnr,
								}
							end,
						}),
						sorter = conf.generic_sorter({}),
						previewer = previewers.new_buffer_previewer({
							title = "Terminal Preview",
							define_preview = function(self, entry)
								local lines = vim.api.nvim_buf_get_lines(entry.value, 0, -1, false)
								vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
							end,
						}),
						attach_mappings = function(prompt_bufnr)
							actions.select_default:replace(function()
								local selection = action_state.get_selected_entry()
								actions.close(prompt_bufnr)
								if not selection then
									return
								end

								local buf = selection.value

								local term_win = nil
								for _, win in ipairs(vim.api.nvim_list_wins()) do
									if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
										term_win = win
										break
									end
								end

								if term_win then
									vim.api.nvim_win_set_buf(term_win, buf)
									vim.api.nvim_set_current_win(term_win)
								else
									vim.cmd("botright 15split")
									vim.api.nvim_win_set_buf(0, buf)
								end

								vim.g.main_term_buf = buf

								vim.schedule(function()
									vim.cmd("startinsert")
								end)
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
								return {
									value = bufnr,
									display = vim.fn.fnamemodify(filename, ":t"),
									ordinal = vim.fn.fnamemodify(filename, ":t"),
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
