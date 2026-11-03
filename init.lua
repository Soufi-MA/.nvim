local nvm_bin = vim.fn.expand("~/.nvm/versions/node/v24.20.0/bin")
vim.env.PATH = nvm_bin .. ":" .. vim.env.PATH
require("core.keymap")
require("core.set")
require("core.lazy")
