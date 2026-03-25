return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = { "n", "v" },
			desc = "Format buffer (Conform)",
		},
	},
	opts = {
		formatters_by_ft = {
			["*"] = { "trim_whitespace" },
			["_"] = { "trim_whitespace" },

			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			svelte = { "prettierd" },
			vue = { "prettierd" },
			css = { "prettierd" },
			scss = { "prettierd" },
			less = { "prettierd" },
			html = { "prettierd" },
			json = { "prettierd" },
			jsonc = { "prettierd" },
			yaml = { "prettierd" },
			markdown = { "prettierd" },
			graphql = { "prettierd" },

			lua = { "stylua" },
		},

		default_format_opts = {
			lsp_format = "fallback",
			timeout_ms = 1000,
		},

		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
}
