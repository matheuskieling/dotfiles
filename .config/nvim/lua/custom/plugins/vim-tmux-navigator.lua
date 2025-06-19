return {
  "christoomey/vim-tmux-navigator",
  lazy = true,
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate to left pane" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate to down pane" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate to up pane" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate to right pane" },
  },
  config = function()
    vim.g.tmux_navigator_no_mappings = 1
  end,
}
