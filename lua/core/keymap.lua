vim.g.mapleader = " "

-- Basic quality-of-life mappings
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "<C-c>", "<ESC>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-f>", "<C-f>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("x", "p", '"_dp')
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

-- Terminal mode escape
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Main terminal management
vim.g.main_term_buf = vim.g.main_term_buf or nil

local function toggle_main_terminal()
	local buf = vim.g.main_term_buf

	if buf and vim.api.nvim_buf_is_valid(buf) then
		local win = vim.fn.bufwinid(buf)
		if win > 0 then
			vim.api.nvim_win_close(win, false) -- hide
		else
			vim.cmd("botright 15split")
			vim.api.nvim_win_set_buf(0, buf)
			vim.cmd("startinsert")
		end
	else
		-- First time creation
		vim.cmd("botright 15split | terminal")
		vim.g.main_term_buf = vim.api.nvim_get_current_buf()
		vim.bo[vim.g.main_term_buf].bufhidden = "hide"
		vim.cmd("startinsert")
	end
end

vim.keymap.set("n", "<leader>tt", toggle_main_terminal, { desc = "Toggle bottom terminal (hide/show)" })

vim.keymap.set("n", "<leader>tk", function()
	local buf = vim.g.main_term_buf
	if buf and vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_buf_delete(buf, { force = true })
		vim.g.main_term_buf = nil
		vim.notify("Main terminal killed", vim.log.levels.INFO)
	else
		vim.notify("No main terminal to kill", vim.log.levels.WARN)
	end
end, { desc = "Kill the main bottom terminal" })

vim.keymap.set("n", "<leader>tn", function()
	local old_buf = vim.g.main_term_buf
	if not old_buf or not vim.api.nvim_buf_is_valid(old_buf) then
		vim.notify("No active main terminal to replace", vim.log.levels.WARN)
		return
	end

	local old_win = vim.fn.bufwinid(old_buf)

	-- Create new terminal in background
	local new_buf = vim.api.nvim_create_buf(true, false)
	vim.api.nvim_buf_call(new_buf, function()
		vim.cmd("terminal")
	end)
	vim.bo[new_buf].bufhidden = "hide"

	-- Replace in existing window if any
	if old_win > 0 then
		vim.api.nvim_win_set_buf(old_win, new_buf)
		vim.api.nvim_set_current_win(old_win)
		vim.cmd("startinsert")
	end

	vim.g.main_term_buf = new_buf
	vim.notify("Main terminal replaced (old one kept alive)", vim.log.levels.INFO)
end, { desc = "Replace active terminal (keeps old buffer in background)" })
