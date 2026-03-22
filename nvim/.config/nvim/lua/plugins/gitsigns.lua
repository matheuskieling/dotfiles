return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local prev_on_attach = opts.on_attach
    opts.on_attach = function(buffer)
      if prev_on_attach then
        prev_on_attach(buffer)
      end
      vim.keymap.set("n", "<leader>gha", function()
        require("gitsigns").setqflist("all")
      end, { buffer = buffer, desc = "All Hunks to Quickfix", silent = true })
    end
  end,
}
