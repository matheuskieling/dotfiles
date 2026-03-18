-- Roslyn LSP for C# (replaces OmniSharp)
return {
  -- Add the custom mason registry that includes roslyn
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
      ensure_installed = {
        "roslyn",
        "csharpier",
      },
    },
  },

  -- Treesitter for C# syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp" } },
  },

  -- Roslyn LSP plugin
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    ---@module 'roslyn.config'
    ---@type RoslynNvimConfig
    opts = {
      broad_search = true,
    },
  },

  -- Formatter for C#
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
      },
    },
  },
}
