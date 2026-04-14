return {
  {
    "jake-stewart/multicursor.nvim",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local map = vim.keymap.set

      -- Add or skip cursor for next/prev match
      map({ "n", "v" }, "<C-n>", function() mc.matchAddCursor(1) end)
      map({ "n", "v" }, "<C-S-n>", function() mc.matchSkipCursor(1) end)
      map({ "n", "v" }, "<C-p>", function() mc.matchAddCursor(-1) end)

      -- Add cursors above/below
      map({ "n", "v" }, "<C-Up>", function() mc.lineAddCursor(-1) end)
      map({ "n", "v" }, "<C-Down>", function() mc.lineAddCursor(1) end)

      -- Select all matches
      map({ "n", "v" }, "<C-S-l>", mc.matchAllAddCursors)

      -- Clear cursors only when they exist, using a keymap layer
      mc.addKeymapLayer(function(layerSet)
        layerSet("n", "<Esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },
}
