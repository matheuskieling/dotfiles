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
      { "<leader>dL", function() vim.cmd("edit " .. vim.fn.stdpath("cache") .. "/dap.log") end, desc = "Open DAP Log" },
    },
    config = function()
      local dap = require("dap")
      dap.set_log_level("INFO")

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "●", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "●", texthl = "DiagnosticHint" })
      vim.fn.sign_define("DapLogPoint", { text = "●", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "Visual" })

      -- Open browser when dotnet app starts (if launchBrowser is set)
      dap.listeners.after.event_initialized.open_browser = function()
        if dotnet_session and dotnet_session.launch_url then
          local url = dotnet_session.launch_url
          vim.defer_fn(function()
            vim.fn.jobstart({ "xdg-open", url }, { detach = true })
          end, 5000)
        end
      end

      ---------------------------------------------------------------
      -- .NET / C# (netcoredbg)
      ---------------------------------------------------------------
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      -- Session state (picked once, used by program/env/cwd)
      local dotnet_session = nil

      local function ensure_dotnet_session()
        if dotnet_session then return dotnet_session end

        local co = coroutine.running()
        local cwd = vim.fn.getcwd()
        dotnet_session = {
          dll = nil,
          cwd = cwd,
          env = { ASPNETCORE_ENVIRONMENT = "Development" },
          launch_url = nil,
        }

        -- Step 1: Pick DLL
        local dlls = vim.fn.glob(cwd .. "/bin/Debug/net*/*.dll", false, true)
        if #dlls == 0 then
          dlls = vim.fn.glob(cwd .. "/**/bin/Debug/net*/*.dll", false, true)
        end
        if #dlls == 0 then
          local input = vim.fn.input("Path to dll: ", cwd .. "/", "file")
          if input == "" then return dotnet_session end
          dotnet_session.dll = input
        elseif #dlls == 1 then
          dotnet_session.cwd = dlls[1]:match("(.+)/bin/")
          dotnet_session.dll = dlls[1]
        else
          local labels = {}
          for i, d in ipairs(dlls) do
            labels[i] = d:sub(#cwd + 2)
          end
          vim.ui.select(labels, { prompt = "Select DLL to debug:" }, function(_, idx)
            if co then
              coroutine.resume(co, idx)
            end
          end)
          local idx = coroutine.yield()
          if not idx then return dotnet_session end
          dotnet_session.cwd = dlls[idx]:match("(.+)/bin/")
          dotnet_session.dll = dlls[idx]
        end

        -- Step 2: Pick launch profile
        local search_dir = dotnet_session.cwd
        local profiles = {}
        local files = vim.fn.glob(search_dir .. "/Properties/launchSettings.json", false, true)
        if #files == 0 then
          files = vim.fn.glob(cwd .. "/**/Properties/launchSettings.json", false, true)
        end
        for _, file in ipairs(files) do
          local ok, content = pcall(vim.fn.readfile, file)
          if ok then
            local json = vim.fn.json_decode(table.concat(content, "\n"))
            if json and json.profiles then
              for name, profile in pairs(json.profiles) do
                profiles[name] = profile
              end
            end
          end
        end

        local names = vim.tbl_keys(profiles)
        if #names == 0 then
          local input = vim.fn.input("ASPNETCORE_ENVIRONMENT: ", "Development")
          dotnet_session.env = { ASPNETCORE_ENVIRONMENT = input }
          return dotnet_session
        end

        table.sort(names)
        vim.ui.select(names, { prompt = "Select launch profile:" }, function(choice)
          if co then
            coroutine.resume(co, choice)
          end
        end)
        local selected = coroutine.yield()

        if not selected then return dotnet_session end

        local profile = profiles[selected]
        local env = profile.environmentVariables or {}
        if profile.applicationUrl then
          env.ASPNETCORE_URLS = profile.applicationUrl
        end
        if profile.launchBrowser and profile.launchUrl then
          local base = profile.applicationUrl or "http://localhost:5000"
          base = base:match("^[^,]+")
          local url = profile.launchUrl
          if not url:match("^https?://") then
            url = base:gsub("0%.0%.0%.0", "localhost") .. "/" .. url
          end
          dotnet_session.launch_url = url
        end
        dotnet_session.env = env
        return dotnet_session
      end

      -- Reset session when debugging ends so next run picks fresh
      dap.listeners.before.event_terminated.reset_dotnet = function() dotnet_session = nil end
      dap.listeners.before.event_exited.reset_dotnet = function() dotnet_session = nil end

      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch - netcoredbg",
          request = "launch",
          program = function()
            local s = ensure_dotnet_session()
            if not s.dll then
              vim.notify("Debug cancelled", vim.log.levels.INFO)
              return dap.ABORT
            end
            return s.dll
          end,
          cwd = function() return ensure_dotnet_session().cwd end,
          env = function() return ensure_dotnet_session().env end,
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
            runtimeExecutable = "pnpm",
            runtimeArgs = { "dev" },
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            resolveSourceMapLocations = {
              "${workspaceFolder}/**",
              "!**/node_modules/**",
            },
            console = "integratedTerminal",
            env = { NO_COLOR = "1" },
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
