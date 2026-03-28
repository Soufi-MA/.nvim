return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"3rd/image.nvim",
	},

	keys = {
		{ "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
		{ "<leader>pf", "<cmd>Telescope git_files<cr>", desc = "Git files" },
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

	config = function()
		require("telescope").setup({
			extensions = {
				fzf = {},
			},
			pickers = {
				find_files = {
					hidden = true,
					no_ignore = true,
				},
			},
		})
		require("telescope").load_extension("fzf")

		local previewers = require("telescope.previewers")
		local image = require("image")

		image.setup({
			backend = "kitty",
			processor = "magick_cli",
			integrations = {
				markdown = { enabled = false },
				neorg = { enabled = false },
			},
		})

		local supported = { "png", "jpg", "jpeg", "gif", "webp", "svg", "avif", "heic" }
		local get_ext = function(path)
			return path:lower():match("^.+%.(%w+)$") or ""
		end

		local current_img = nil
		local last_path = ""

		local clear = function()
			if current_img then
				current_img:clear()
				current_img = nil
			end
		end

		local buffer_previewer_maker = function(filepath, bufnr, opts)
			opts = opts or {}
			if last_path ~= filepath then
				clear()
			end
			last_path = filepath

			if vim.tbl_contains(supported, get_ext(filepath)) then
				current_img = image.from_file(filepath, { window = opts.winid, buffer = bufnr })
				if current_img then
					current_img:render()
				end
			else
				previewers.buffer_previewer_maker(filepath, bufnr, opts)
			end
		end

		require("telescope.config").values.buffer_previewer_maker = buffer_previewer_maker
	end,
}
