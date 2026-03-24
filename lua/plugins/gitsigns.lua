return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        signs = {
            add          = { text = "▎" },
            change       = { text = "▎" },
            delete       = { text = "▁" },
            topdelete    = { text = "▔" },
            changedelete = { text = "▎" },
            untracked    = { text = "▎" },
        },
        signcolumn = true,
        numhl      = false,
        linehl     = false,
        word_diff  = false,
        watch_gitdir = { interval = 1000, follow_files = true },
        attach_to_untracked = true,
        current_line_blame = false,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
        },
        on_attach = function(bufnr)
            local gs = require("gitsigns")
            vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr })
        end,
    },
}
