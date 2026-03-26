-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here


vim.keymap.set("n", "<leader>oi", function()
  vim.lsp.buf.code_action({
    context = { only = { "source.removeUnusedImports", "source.fixAll" } },
    apply = true,
  })
end, { desc = "Optimize Imports" })
