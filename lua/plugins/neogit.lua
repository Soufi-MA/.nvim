return {
    "NeogitOrg/neogit",
    lazy = true,
    dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional
        "nvim-telescope/telescope.nvim", -- optional
    },
    cmd = "Neogit",
    keys = {
        { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" }
    },
    config = function()
        require("neogit").setup({
            integrations = {
                diffview = true,
                telescope = true,
            },
        })
    end,
}
