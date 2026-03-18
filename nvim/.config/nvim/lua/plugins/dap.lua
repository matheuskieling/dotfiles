return {
  -- Mason-DAP bridge: auto-install debug adapters
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "coreclr", "js" },
      automatic_installation = true,
      handlers = {
        coreclr = function() end,
        js = function() end,
      },
    },
  },

  -- Core DAP plugin
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional Breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    },
    config = function()
      local dap = require("dap")

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "●", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DapLogPoint", { text = "●", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "Visual" })

      ---------------------------------------------------------------
      -- .NET / C# (netcoredbg)
      ---------------------------------------------------------------
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      local function pick_dotnet_dll()
        local co = coroutine.running()
        local cwd = vim.fn.getcwd()
        local dlls = vim.fn.glob(cwd .. "/bin/Debug/net*/*.dll", false, true)
        if #dlls == 0 then
          dlls = vim.fn.glob(cwd .. "/**/bin/Debug/net*/*.dll", false, true)
        end
        if #dlls == 0 then
          local input = vim.fn.input("Path to dll: ", cwd .. "/", "file")
          if input == "" then return nil end
          return input
        elseif #dlls == 1 then
          return dlls[1]
        else
          -- Show relative paths in picker
          local labels = {}
          for i, dll in ipairs(dlls) do
            labels[i] = dll:sub(#cwd + 2)
          end
          vim.ui.select(labels, { prompt = "Select DLL to debug:" }, function(choice, idx)
            if co then
              coroutine.resume(co, idx and dlls[idx] or nil)
            end
          end)
          return coroutine.yield()
        end
      end

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch - netcoredbg",
          request = "launch",
          program = function()
            local dll = pick_dotnet_dll()
            if not dll then
              vim.notify("Debug cancelled", vim.log.levels.INFO)
              return dap.ABORT
            end
            return dll
          end,
          cwd = "${workspaceFolder}",
          env = {
            ASPNETCORE_ENVIRONMENT = "Development",
          },
        },
        {
          type = "coreclr",
          name = "Attach - netcoredbg",
          request = "attach",
          processId = require("dap.utils").pick_process,
        },
      }
      dap.configurations.fsharp = dap.configurations.cs

      ---------------------------------------------------------------
      -- JavaScript / TypeScript / Next.js (js-debug-adapter)
      ---------------------------------------------------------------
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "::1",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }

      dap.adapters["pwa-chrome"] = {
        type = "server",
        host = "::1",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }

      for _, ft in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[ft] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach (port 9229)",
            address = "localhost",
            port = 9229,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            restart = true,
            skipFiles = { "<node_internals>/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            sourceMaps = true,
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch Next.js dev",
            runtimeExecutable = "npm",
            runtimeArgs = { "run", "dev" },
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
            console = "integratedTerminal",
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Launch Chrome (localhost:3000)",
            url = "http://localhost:3000",
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
          },
        }
      end
    end,
  },

  -- DAP UI
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    keys = {
      { "<leader>du", function() require("dapui").toggle({}) end, desc = "Dap UI" },
      { "<leader>de", function() require("dapui").eval() end, desc = "Eval under cursor", mode = { "n", "v" } },
      { "<leader>dE", function() require("dapui").eval(vim.fn.input("Expression: ")) end, desc = "Eval expression" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup({
        controls = { enabled = false },
        layouts = {
          {
            elements = {
              { id = "scopes", size = 1 },
            },
            position = "left",
            size = 40,
          },
          {
            elements = {
              { id = "repl", size = 1 },
            },
            position = "bottom",
            size = 10,
          },
        },
      })

      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
    end,
  },

  -- Virtual text: show variable values inline
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {},
  },
}
