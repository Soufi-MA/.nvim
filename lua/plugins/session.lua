return {
	"rmagatti/auto-session",
	lazy = false,
	priority = 100,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	opts = {
		enabled = true,
		auto_save = true,
		auto_restore = true,
		auto_create = true,
		auto_restore_last_session = true,
		single_session_mode = false,

		session_lens = {
			picker = "telescope",
			load_on_setup = true,
			previewer = "summary",
			picker_opts = {
				-- matches your telescope style if you want
				-- theme = "dropdown",        -- or "ivy", "cursor", etc.
			},
		},

		root_dir = vim.fn.stdpath("data") .. "/sessions/",
		auto_delete_empty_sessions = true,

		close_unsupported_windows = true,
		close_filetypes_on_save = { "checkhealth" },
	},
	init = function()
		vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
	end,
}
