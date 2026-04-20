return {
  -- Oil.nvim - vim-vinegar style file explorer
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
      {
        "<leader>e",
        function()
          local oil = require("oil")
          if vim.bo.filetype == "oil" then
            oil.close()
          else
            oil.open()
          end
        end,
        desc = "Explorer toggle (Oil)",
      },
      { "<leader>E", function() require("oil").toggle_float() end, desc = "Explorer float (Oil)" },
    },
    opts = {
      default_file_explorer = true,
      skip_confirm_for_simple_edits = true,
      columns = { "icon" },
      view_options = {
        show_hidden = true,
        natural_order = true,
      },
    },
  },

  -- Disable neo-tree
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}
