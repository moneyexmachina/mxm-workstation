local venv = require "utils.venv"

return {
  "mason-org/mason-lspconfig.nvim",
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup {
      ensure_installed = { "pyright", "lua_ls" },
      automatic_enable = true,
    }

    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" }, -- Neovim runs LuaJIT
          diagnostics = {
            globals = { "vim" }, -- prevent "undefined global 'vim'" warnings
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true), -- make server aware of runtime files
            checkThirdParty = false, -- don't nag about "love" or "jit"
          },
          telemetry = { enable = false },
        },
      },
    })
    vim.lsp.config("pyright", {
      settings = {
        python = {
          pythonPath = venv.get_python_path(vim.fn.getcwd()),
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            useLibraryCodeForTypes = true,
          },
        },
      },
    })
  end,
}
