-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Center cursor after vertical movements
vim.keymap.set("n", "j", "gjzz", { desc = "Move down (visual line) and center" })
vim.keymap.set("n", "k", "gkzz", { desc = "Move up (visual line) and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half page and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half page and center" })
