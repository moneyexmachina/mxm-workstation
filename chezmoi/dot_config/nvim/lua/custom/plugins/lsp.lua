local keymaps = require "custom.keymaps"

return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "saghen/blink.cmp",
  },
  opts = {
    servers = {},
  },

  config = function(_, opts)
    local lspconfig = require "lspconfig"
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        -- === Centralized Keymaps ===
        for _, map in ipairs(keymaps.lsp) do
          local keys, func, desc, mode = map[1], map[2], map[3], map[4] or "n"
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
        ---@param client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@param bufnr? integer some lsp support methods only in specific files
        ---@return boolean
        local function client_supports_method(client, method, bufnr)
          return client:supports_method(method, bufnr)
        end

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
          client
          and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
        then
          local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
            end,
          })
        end

        -- The following code creates a keymap to toggle inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          vim.keymap.set("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
          end, { buffer = event.buf, desc = "LSP: [T]oggle Inlay [H]ints" })
        end
      end,
    })

    -- Diagnostic Config
    -- See :help vim.diagnostic.Opts

    vim.diagnostic.config {
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      } or {},
      -- Turn off end-of-line text
      virtual_text = false,
      -- Turn on multi-line messages below the code line
      virtual_lines = true,
    }

    --		vim.diagnostic.config {
    --      severity_sort = true,
    --      float = { border = "rounded", source = "if_many" },
    --      underline = { severity = vim.diagnostic.severity.ERROR },
    --      signs = vim.g.have_nerd_font and {
    --        text = {
    --          [vim.diagnostic.severity.ERROR] = "󰅚 ",
    --          [vim.diagnostic.severity.WARN] = "󰀪 ",
    --          [vim.diagnostic.severity.INFO] = "󰋽 ",
    --          [vim.diagnostic.severity.HINT] = "󰌶 ",
    --        },
    --      } or {},
    --      virtual_text = {
    --        source = "if_many",
    --        spacing = 2,
    --        format = function(diagnostic)
    --          local diagnostic_message = {
    --            [vim.diagnostic.severity.ERROR] = diagnostic.message,
    --            [vim.diagnostic.severity.WARN] = diagnostic.message,
    --            [vim.diagnostic.severity.INFO] = diagnostic.message,
    --            [vim.diagnostic.severity.HINT] = diagnostic.message,
    --          }
    --          return diagnostic_message[diagnostic.severity]
    --        end,
    --      },
    --    }
    -- === Mason tool installer ===
    local ensure_installed = vim.tbl_keys(opts.servers or {})
    vim.list_extend(ensure_installed, { "stylua" })
    require("mason-tool-installer").setup { ensure_installed = ensure_installed }

    -- === Language servers ===
    -- Configure all servers except pyright here (pyright lives in mason-lspconfig.lua)
    for name, cfg in pairs(opts.servers or {}) do
      if name ~= "pyright" then
        vim.lsp.config(name, cfg)
      end
    end
  end,
}
