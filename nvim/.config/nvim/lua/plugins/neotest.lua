return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "Issafalcon/neotest-dotnet",
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-dotnet"] = {
          discovery_root = "solution",
          dap = {
            adapter_name = "netcoredbg",
          },
        },
        ["neotest-vitest"] = {},
      },
    },
  },
}
