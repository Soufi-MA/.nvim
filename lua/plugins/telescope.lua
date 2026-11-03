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
		local image = require("image")
		local previewers = require("telescope.previewers")

		-- Image.nvim setup
		image.setup({
			backend = "kitty",
			processor = "magick_cli",
			integrations = {
				markdown = { enabled = false },
				neorg = { enabled = false },
			},
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = 85, -- leave room for the dimensions label
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		})

		require("telescope").setup({
			defaults = {
				layout_config = {
					preview_width = 0.6,
				},
			},
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

		-------------------------------------------------
		-- Image preview + dimensions label
		-------------------------------------------------
		local supported = {
			png = true,
			jpg = true,
			jpeg = true,
			gif = true,
			webp = true,
		}

		local function is_image(path)
			local ext = path:lower():match("%.([%w]+)$")
			return ext and supported[ext]
		end

		local current_img = nil
		local dim_win = nil
		local dim_buf = nil

		local function clear_image()
			if current_img then
				pcall(function()
					current_img:clear()
				end)
				current_img = nil
			end
			pcall(image.clear)

			if dim_win and vim.api.nvim_win_is_valid(dim_win) then
				pcall(vim.api.nvim_win_close, dim_win, true)
			end
			dim_win = nil

			if dim_buf and vim.api.nvim_buf_is_valid(dim_buf) then
				pcall(vim.api.nvim_buf_delete, dim_buf, { force = true })
			end
			dim_buf = nil
		end

		local buffer_previewer_maker = function(filepath, bufnr, opts)
			opts = opts or {}
			filepath = vim.fn.expand(filepath)

			clear_image()

			if not is_image(filepath) then
				previewers.buffer_previewer_maker(filepath, bufnr, opts)
				return
			end

			vim.defer_fn(function()
				if not vim.api.nvim_win_is_valid(opts.winid) or not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end

				-- Clear the preview buffer
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

				local ok, img = pcall(image.from_file, filepath, {
					window = opts.winid,
					buffer = bufnr,
					with_virtual_padding = true,
				})

				if not (ok and img) then
					previewers.buffer_previewer_maker(filepath, bufnr, opts)
					return
				end

				current_img = img
				pcall(function()
					img:render()
				end)

				-- Dimensions floating window (bottom center)
				local w = img.image_width or "?"
				local h = img.image_height or "?"
				local info = string.format(" %s × %s px ", w, h)

				dim_buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(dim_buf, 0, -1, false, { info })

				local win_width = vim.api.nvim_win_get_width(opts.winid)
				local win_height = vim.api.nvim_win_get_height(opts.winid)
				local text_width = vim.fn.strdisplaywidth(info)

				dim_win = vim.api.nvim_open_win(dim_buf, false, {
					relative = "win",
					win = opts.winid,
					width = text_width,
					height = 1,
					row = win_height - 2, -- near bottom
					col = math.floor((win_width - text_width) / 2),
					style = "minimal",
					border = "none",
					focusable = false,
					zindex = 50,
				})

				vim.api.nvim_set_option_value("winhl", "Normal:Comment", { win = dim_win })
			end, 30)
		end

		require("telescope.config").values.buffer_previewer_maker = buffer_previewer_maker

		-- Cleanup when preview closes
		vim.api.nvim_create_autocmd("User", {
			pattern = "TelescopePreviewerClosed",
			callback = clear_image,
		})

		vim.api.nvim_create_autocmd("BufLeave", {
			pattern = "Telescope*",
			callback = clear_image,
		})
	end,
}
