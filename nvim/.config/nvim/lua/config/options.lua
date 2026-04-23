-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true
vim.g.autoformat = false
vim.opt.scrolloff = 999
-- Workaround: Neovim inlay hint col out of range bug (neovim/neovim#36318)
-- Catches the stale col error at render time, clamps and retries
local orig_set_extmark = vim.api.nvim_buf_set_extmark
vim.api.nvim_buf_set_extmark = function(bufnr, ns_id, line, col, opts)
  local ok, result = pcall(orig_set_extmark, bufnr, ns_id, line, col, opts)
  if ok then
    return result
  end
  if type(result) == "string" and result:match("out of range") then
    local line_text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]
    if line_text then
      return orig_set_extmark(bufnr, ns_id, line, math.min(col, #line_text), opts)
    end
  end
  error(result)
end
