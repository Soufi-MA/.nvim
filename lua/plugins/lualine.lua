return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status")

		local colors = {
			color0 = "#092236",
			color1 = "#ff5874",
			color2 = "#c3ccdc",
			color3 = "#1c1e26",
			color6 = "#a1aab8",
			color7 = "#828697",
			color8 = "#ae81ff",
		}
		local my_lualine_theme = {
			replace = {
				a = { fg = colors.color0, bg = colors.color1, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
			inactive = {
				a = { fg = colors.color6, bg = colors.color3, gui = "bold" },
				b = { fg = colors.color6, bg = colors.color3 },
				c = { fg = colors.color6, bg = colors.color3 },
			},
			normal = {
				a = { fg = colors.color0, bg = colors.color7, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
				c = { fg = colors.color2, bg = colors.color3 },
			},
			visual = {
				a = { fg = colors.color0, bg = colors.color8, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
			insert = {
				a = { fg = colors.color0, bg = colors.color2, gui = "bold" },
				b = { fg = colors.color2, bg = colors.color3 },
			},
		}

		local mode = {
			"mode",
			fmt = function(str)
				return str
			end,
		}

		local diff = {
			"diff",
			colored = true,
			symbols = { added = " ", modified = " ", removed = " " },
		}

		local function get_project_filename()
			local bufname = vim.api.nvim_buf_get_name(0)
			if bufname == "" then
				return "[No Name]"
			end

			local root_markers = {
				".git",
				"package.json",
				"Cargo.toml",
				"go.mod",
				"pyproject.toml",
				"tsconfig.json",
			}

			local root = vim.fs.root(0, root_markers) or vim.fn.getcwd()

			local rel_path = bufname
			if root and bufname:find("^" .. vim.pesc(root) .. "/") then
				rel_path = bufname:sub(#root + 2)
			else
				rel_path = vim.fn.fnamemodify(bufname, ":~:.")
			end

			local status = ""
			if vim.bo.readonly then
				status = status .. " [RO]"
			end
			if vim.bo.modified then
				status = status .. " [+]"
			end

			return rel_path .. status
		end

		local filename = { get_project_filename }

		local branch = { "branch", icon = { "", color = { fg = "#A6D4DE" } }, "|" }

		lualine.setup({
			icons_enabled = true,
			options = {
				theme = my_lualine_theme,
				component_separators = { left = "|", right = "|" },
				section_separators = { left = "|", right = "" },
			},
			sections = {
				lualine_a = { mode },
				lualine_b = { branch },
				lualine_c = { diff, filename },
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
					{ "filetype" },
				},
			},
		})
	end,
}
