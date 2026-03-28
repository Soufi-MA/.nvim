return {
	"mason-org/mason-lspconfig.nvim",
	event = { "BufReadPre" },
	cmd = { "LspInfo", "LspStart", "LspStop", "LspRestart", "LspInstall" },
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"neovim/nvim-lspconfig",
	},
	opts = {
		ensure_installed = {
			"lua_ls",
			"vtsls",
			"tailwindcss",
			"eslint",
			"cssls",
			"html",
			"jsonls",
		},
	},
	config = function(_, opts)
		local on_attach = function(_, bufnr)
			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, {
					buffer = bufnr,
					desc = desc,
					silent = true,
					noremap = true,
				})
			end

			map("n", "gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
			map("n", "gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
			map("n", "gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
			map("n", "gr", vim.lsp.buf.references, "[G]oto [R]eferences")

			map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
			map("n", "<leader>vd", vim.diagnostic.open_float, "[V]iew [D]iagnostics")

			map("n", "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

			map("n", "[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
			map("n", "]d", vim.diagnostic.goto_next, "Next Diagnostic")
		end

		local capabilities = require("blink.cmp").get_lsp_capabilities()

		for _, server_name in ipairs(opts.ensure_installed) do
			local server_opts = {
				on_attach = on_attach,
				capabilities = capabilities,
			}
			if server_name == "lua_ls" then
				server_opts.settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = { checkThirdParty = false },
						telemetry = { enable = false },
					},
				}
			end
			vim.lsp.config(server_name, server_opts)
		end

		require("mason-lspconfig").setup(opts)
	end,
}
