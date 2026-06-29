-- =============================================================================
--  keymaps.lua - Centralized Keybindings for Neovim (with Lazy.nvim)
-- =============================================================================

local M = {}

-- ---------------------------------------------------------------------------
--  Global Editing & Navigation
-- ---------------------------------------------------------------------------
M.global = {
  { 'n', '<leader>w', ':w<CR>', { desc = 'Save file' } },
  { 'n', '<leader>q', ':q<CR>', { desc = 'Quit' } },
  { 'n', '<leader>h', ':nohlsearch<CR>', { desc = 'No highlight' } },
  -- Disable arrow keys in normal mode
  { 'n', '<left>', '<cmd>echo "Use h to move!!"<CR>', {} },
  { 'n', '<right>', '<cmd>echo "Use l to move!!"<CR>', {} },
  { 'n', '<up>', '<cmd>echo "Use k to move!!"<CR>', {} },
  { 'n', '<down>', '<cmd>echo "Use j to move!!"<CR>', {} },
  -- Window navigation
  { 'n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' } },
  { 'n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' } },
  { 'n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' } },
  { 'n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' } },
  -- Buffer management
  { 'n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' } },
  { 'n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' } },
  { 'n', '<leader>bd', ':bdelete<CR>', { desc = 'Delete buffer' } },
  { 'n', '<leader>bl', ':ls<CR>:b<Space>', { desc = 'List buffers' } },
  -- Misc
  { 'n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear highlights' } },
  { 'n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' } },
  -- Terminal: Exit mode
  { 't', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' } },
}

-- ---------------------------------------------------------------------------
--  Telescope/Fuzzy Finding
-- ---------------------------------------------------------------------------
M.telescope = {
  {
    '<leader>sf',
    function()
      require('telescope.builtin').find_files()
    end,
    desc = '[S]earch [F]iles',
  },
  {
    '<leader>sg',
    function()
      require('telescope.builtin').live_grep()
    end,
    desc = '[S]earch by [G]rep',
  },
  {
    '<leader>sb',
    function()
      require('telescope.builtin').buffers()
    end,
    desc = '[S]earch [B]uffers',
  },
  {
    '<leader>sh',
    function()
      require('telescope.builtin').help_tags()
    end,
    desc = '[S]earch [H]elp',
  },
  {
    '<leader>sk',
    function()
      require('telescope.builtin').keymaps()
    end,
    desc = '[S]earch [K]eymaps',
  },
  {
    '<leader>ss',
    function()
      require('telescope.builtin').builtin()
    end,
    desc = '[S]elect Telescope picker',
  },
  {
    '<leader>sw',
    function()
      require('telescope.builtin').grep_string()
    end,
    desc = '[S]earch current [W]ord',
  },
  {
    '<leader>sd',
    function()
      require('telescope.builtin').diagnostics()
    end,
    desc = '[S]earch [D]iagnostics',
  },
  {
    '<leader>sr',
    function()
      require('telescope.builtin').resume()
    end,
    desc = '[S]earch [R]esume',
  },
  {
    '<leader>s.',
    function()
      require('telescope.builtin').oldfiles()
    end,
    desc = '[S]earch Recent Files',
  },
  {
    '<leader><leader>',
    function()
      require('telescope.builtin').buffers()
    end,
    desc = 'Find existing buffers',
  },
  -- Fuzzy find in current buffer (dropdown theme)
  {
    '<leader>/',
    function()
      require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })
    end,
    desc = 'Fuzzily search in current buffer',
  },
  -- Grep open files only
  {
    '<leader>s/',
    function()
      require('telescope.builtin').live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    desc = '[S]earch [/] in Open Files',
  },
  -- Search Neovim config
  {
    '<leader>sn',
    function()
      require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' }
    end,
    desc = '[S]earch [N]eovim files',
  },
}

-- ---------------------------------------------------------------------------
--  Gitsigns
-- ---------------------------------------------------------------------------
M.gitsigns = {
  {
    '<leader>gs',
    function()
      require('gitsigns').stage_hunk()
    end,
    desc = 'Git [S]tage Hunk',
  },
  {
    '<leader>gd',
    function()
      require('gitsigns').diffthis()
    end,
    desc = 'Git [D]iff',
  },
  -- Add more as needed...
}

-- ---------------------------------------------------------------------------
--  LSP (Language Server Protocol) - Buffer-local, used in on_attach
-- ---------------------------------------------------------------------------
M.lsp = {
  { 'grn', vim.lsp.buf.rename, '[R]e[n]ame' },
  { 'gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' } },
  {
    'grr',
    function()
      require('telescope.builtin').lsp_references()
    end,
    '[G]oto [R]eferences',
  },
  {
    'gri',
    function()
      require('telescope.builtin').lsp_implementations()
    end,
    '[G]oto [I]mplementation',
  },
  {
    'grd',
    function()
      require('telescope.builtin').lsp_definitions()
    end,
    '[G]oto [D]efinition',
  },
  { 'grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration' },
  {
    'gO',
    function()
      require('telescope.builtin').lsp_document_symbols()
    end,
    'Open Document Symbols',
  },
  {
    'gW',
    function()
      require('telescope.builtin').lsp_dynamic_workspace_symbols()
    end,
    'Open Workspace Symbols',
  },
  {
    'grt',
    function()
      require('telescope.builtin').lsp_type_definitions()
    end,
    '[G]oto [T]ype Definition',
  },
  -- Add more as needed...
}

-- ---------------------------------------------------------------------------
--  Format/Conform
-- ---------------------------------------------------------------------------
M.format = {
  {
    '<leader>f',
    function()
      require('conform').format { async = true, lsp_format = 'fallback' }
    end,
    desc = '[F]ormat buffer',
  },
}

-- ---------------------------------------------------------------------------
--  TODO: Add more plugin-specific keymaps as you add plugins (treesitter, mini, etc.)
-- ---------------------------------------------------------------------------

return M
