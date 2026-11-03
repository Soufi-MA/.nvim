return {
	"mason-org/mason-lspconfig.nvim",
	event = { "BufReadPre", "BufNewFile" },
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
			"prettierd",
			"cssls",
			"html",
			"jsonls",
			"eslint",
		},
		automatic_enable = true,
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

		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		vim.lsp.config("vtsls", {
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				vtsls = {
					experimental = {
						completion = {
							enableServerSideFuzzyMatch = true,
							entriesLimit = 50,
						},
					},
				},
				typescript = {
					tsserver = {
						maxTsServerMemory = 8192,
					},
				},
			},
		})

		vim.lsp.config("lua_ls", {
			on_attach = on_attach,
			capabilities = capabilities,
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
					workspace = { checkThirdParty = false },
					telemetry = { enable = false },
				},
			},
		})

		vim.lsp.config("tailwindcss", {
			on_attach = on_attach,
			capabilities = capabilities,
		})

		vim.lsp.config("cssls", {
			on_attach = on_attach,
			capabilities = capabilities,
		})

		vim.lsp.config("html", {
			on_attach = on_attach,
			capabilities = capabilities,
		})

		vim.lsp.config("jsonls", {
			on_attach = on_attach,
			capabilities = capabilities,
		})

		-- eslint (with flat config support for ESLint v9)
		vim.lsp.config("eslint", {
			on_attach = function(client, bufnr)
				on_attach(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function() end,
				})
			end,
			capabilities = capabilities,
			settings = {
				experimental = {
					useFlatConfig = true,
				},
				codeActionOnSave = {
					enable = false,
					mode = "all",
				},
				format = false,
			},
		})

		require("mason-lspconfig").setup(opts)
	end,
}
