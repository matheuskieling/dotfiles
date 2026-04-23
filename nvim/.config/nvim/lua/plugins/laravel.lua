return {
  -- Mason: install intelephense and pint
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "intelephense",
        "pint",
      },
    },
  },

  -- Treesitter: PHP and Blade syntax
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "php", "blade" } },
  },

  -- Intelephense LSP
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          filetypes = { "php", "blade" },
          init_options = {
            globalStoragePath = vim.fn.expand("~/.local/share/intelephense"),
          },
          settings = {
            intelephense = {
              files = {
                maxSize = 5000000,
              },
              hints = {
                parameterNames = { enabled = "none" },
                variableTypes = { enabled = false },
                propertyTypes = { enabled = false },
                functionReturnTypes = { enabled = false },
              },
            },
          },
        },
      },
    },
  },

  -- Laravel.nvim (adalessa)
  {
    "adalessa/laravel.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
    },
    ft = { "php", "blade" },
    event = { "BufEnter composer.json" },
    keys = {
      { "<leader>ll", function() Laravel.pickers.laravel() end, desc = "Laravel Picker" },
      { "<leader>la", function() Laravel.pickers.artisan() end, desc = "Laravel Artisan" },
      { "<leader>lr", function() Laravel.pickers.routes() end, desc = "Laravel Routes" },
      { "<leader>lm", function() Laravel.pickers.make() end, desc = "Laravel Make" },
      { "<leader>lc", function() Laravel.pickers.commands() end, desc = "Laravel Commands" },
      { "<leader>lo", function() Laravel.pickers.resources() end, desc = "Laravel Resources" },
      { "<leader>lt", function() Laravel.commands.run("actions") end, desc = "Laravel Actions" },
      { "<leader>lp", function() Laravel.commands.run("command_center") end, desc = "Laravel Command Center" },
      { "<leader>lu", function() Laravel.commands.run("hub") end, desc = "Laravel Hub" },
      {
        "gf",
        function()
          local ok, res = pcall(function()
            if Laravel.app("gf").cursorOnResource() then
              return "<cmd>lua Laravel.commands.run('gf')<cr>"
            end
          end)
          if not ok or not res then
            return "gf"
          end
          return res
        end,
        ft = { "php", "blade" },
        expr = true,
        noremap = true,
        desc = "Laravel Go to File",
      },
    },
    opts = {
      features = {
        pickers = {
          provider = "snacks",
        },
      },
    },
  },

  -- Formatter: Laravel Pint
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        php = { "pint" },
        blade = { "blade-formatter", "pint" },
      },
    },
  },

  -- Blade filetype detection
  {
    "jwalton512/vim-blade",
    ft = "blade",
  },
}
