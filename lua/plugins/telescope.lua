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
