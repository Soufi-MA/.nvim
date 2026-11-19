return {
	"toppair/peek.nvim",
	ft = "markdown",
	build = "deno task --quiet build:fast",
	keys = {
		{
			"<leader>md",
			function()
				local peek = require("peek")
				if peek.is_open() then
					peek.close()
				else
					peek.open()
				end
			end,
			ft = "markdown",
			desc = "Toggle Markdown preview",
		},
	},
	config = function()
		-- webview_deno needs WebKitGTK 4.0; point it at the 4.1 compat symlinks
		vim.env.LD_LIBRARY_PATH = vim.fn.expand("~/.local/lib/webkit-compat")
			.. (vim.env.LD_LIBRARY_PATH and (":" .. vim.env.LD_LIBRARY_PATH) or "")

		require("peek").setup({
			app = "webview",
			filetype = { "markdown" },
			auto_load = true, -- follow the buffer you switch to
			close_on_bdelete = true,
			syntax = true,
			theme = "dark",
		})

		vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
		vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
	end,
}
