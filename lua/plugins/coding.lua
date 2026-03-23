local python_util = require("util.python")

return {
  -- LazyVim ships blink.cmp by default; disable it in favour of nvim-cmp
  { "saghen/blink.cmp", enabled = false },

  {
    "hrsh7th/nvim-cmp",
    enabled = true,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "python",
        "lua",
        "go",
        "yaml",
        "markdown",
        "html",
        "c",
        "bash",
        "query",
        "ninja",
        "rst",
        "json",
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if ok then
        opts.capabilities = vim.tbl_deep_extend("force", opts.capabilities or {}, cmp_nvim_lsp.default_capabilities())
      end

      opts.servers = opts.servers or {}
      opts.servers.pyright = {
        before_init = function(_, config)
          config.settings.python.pythonPath = python_util.get_python_path()
        end,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              diagnosticMode = "workspace",
              autoSearchPaths = true,
              autoImportCompletions = true,
            },
          },
        },
      }

      -- Ruff for fast import fixing and linting code actions
      opts.servers.ruff = {
        init_options = {
          settings = {
            lint = { select = { "F", "I" } },
          },
        },
        on_attach = function(client, bufnr)
          -- Disable hover in favour of pyright
          client.server_capabilities.hoverProvider = false
          -- Organise imports on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.code_action({
                context = { only = { "source.organizeImports" }, diagnostics = {} },
                apply = true,
              })
            end,
          })
        end,
      }
    end,
    keys = {
      { "<leader>pi", "<cmd>LspInfo<cr>", desc = "Python LSP Info" },
      { "<leader>pr", "<cmd>LspRestart pyright<cr>", desc = "Restart Pyright" },
      {
        "<leader>pI",
        function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" }, diagnostics = {} },
            apply = true,
          })
        end,
        desc = "Organise Imports",
      },
    },
  },

  -- Install development tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "pyright",
        "debugpy",
        "ruff",
      })
    end,
  },

  -- Python debugging
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          require("dap-python").setup(python_util.get_python_path())
        end,
      },
    },
    keys = {
      { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug Nearest" },
    },
  },

  -- GitHub
  {
    "almo7aya/openingh.nvim",
    lazy = true,
    cmd = { "OpenInGHFile", "OpenInGHRepo" },
  },

  -- Python test runner
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          runner = "pytest",
          python = function()
            return python_util.get_python_path()
          end,
        },
      },
    },
    config = function(_, opts)
      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters) do
          if type(name) == "number" then
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif meta and meta.__call then
                adapter = adapter(config)
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end
      require("neotest").setup(opts)
    end,
    -- stylua: ignore
    keys = {
      { "<leader>t",  "",                                                                        desc = "+test" },
      { "<leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end,             desc = "Run File" },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end,                  desc = "Run All Test Files" },
      { "<leader>tr", function() require("neotest").run.run() end,                              desc = "Run Nearest" },
      { "<leader>tl", function() require("neotest").run.run_last() end,                         desc = "Run Last" },
      { "<leader>ts", function() require("neotest").summary.toggle() end,                       desc = "Toggle Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end,                  desc = "Toggle Output Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end,                             desc = "Stop" },
    },
  },
}
