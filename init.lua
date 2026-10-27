-- ============================================================================
-- Neovim config: vim, plus the handful of things worth a plugin.
--
-- No LSP, no completion engine, no diagnostics. GHC and ghci report errors;
-- :make pulls them into the quickfix list (see after/ftplugin/haskell.lua).
-- ============================================================================

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ----------------------------------------------------------------------------
-- Options
-- ----------------------------------------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes' -- keeps the gutter from jumping around
vim.opt.showmode = false -- the statusline already says it

vim.opt.mouse = 'a'
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.confirm = true -- prompt instead of erroring on unsaved changes

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = 'split' -- live preview of :s

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.updatetime = 250
vim.opt.timeoutlen = 400

-- Share the system clipboard. Deferred so it doesn't slow down startup.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Brief flash on yank, so you can see what you grabbed.
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- ----------------------------------------------------------------------------
-- Keymaps
-- ----------------------------------------------------------------------------

local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Windows
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Window left' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Window down' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Window up' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Window right' })
map('n', '<leader>v', '<cmd>vsplit<CR>', { desc = 'Split vertical' })
map('n', '<leader>s', '<cmd>split<CR>', { desc = 'Split horizontal' })

-- Buffers. <Tab>/<S-Tab> cycle; ]b/[b do the same if you want <C-i> back
-- for jumplist-forward (in most terminals <Tab> and <C-i> are the same key).
map('n', '<Tab>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<S-Tab>', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
map('n', ']b', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '[b', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })

-- Close the buffer without taking the window layout down with it.
map('n', '<leader>x', function()
  local buf = vim.api.nvim_get_current_buf()
  vim.cmd 'bprevious'
  pcall(vim.api.nvim_buf_delete, buf, {})
end, { desc = 'Close buffer' })

-- Quickfix: where :make puts compiler errors.
map('n', ']q', '<cmd>cnext<CR>zz', { desc = 'Next quickfix item' })
map('n', '[q', '<cmd>cprevious<CR>zz', { desc = 'Previous quickfix item' })
map('n', '<leader>q', function()
  local open = false
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      open = true
    end
  end
  vim.cmd(open and 'cclose' or 'copen')
end, { desc = 'Toggle quickfix list' })

-- ----------------------------------------------------------------------------
-- Plugins (lazy.nvim)
-- ----------------------------------------------------------------------------

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

  -- Theme --------------------------------------------------------------------
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
    config = function()
      require('rose-pine').setup {
        styles = { comments = { italic = false } },
      }
      vim.cmd.colorscheme 'rose-pine'
    end,
  },

  -- Match this file's existing indentation instead of guessing.
  'tpope/vim-sleuth',

  -- Syntax highlighting ------------------------------------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'haskell',
        'lua',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Auto-close brackets, quotes, etc. ---------------------------------------
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {
      check_ts = true, -- don't pair inside strings/comments
    },
  },

  -- Buffer tab bar -----------------------------------------------------------
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = 'VeryLazy',
    -- <leader>1..9 jump to that numbered tab. Declared here rather than in
    -- config so they work on the very first keypress, before VeryLazy fires.
    keys = (function()
      local keys = {}
      for i = 1, 9 do
        keys[i] = { '<leader>' .. i, '<cmd>BufferLineGoToBuffer ' .. i .. '<CR>', desc = 'Go to buffer ' .. i }
      end
      return keys
    end)(),
    opts = {
      options = {
        numbers = 'ordinal', -- the number matches <leader>1..9
        show_buffer_icons = false,
        show_close_icon = false,
        separator_style = 'thin',
        diagnostics = false,
        always_show_bufferline = false,
      },
    },
  },

  -- Fuzzy finding ------------------------------------------------------------
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          layout_strategy = 'flex',
          mappings = { i = { ['<Esc>'] = require('telescope.actions').close } },
        },
      }
      pcall(require('telescope').load_extension, 'fzf')

      local t = require 'telescope.builtin'
      map('n', '<leader>f', t.find_files, { desc = 'Find file' })
      map('n', '<leader>b', t.buffers, { desc = 'Find buffer' })
      map('n', '<leader>g', t.live_grep, { desc = 'Grep in project' })
      map('n', '<leader>*', t.grep_string, { desc = 'Grep word under cursor' })
      map('n', '<leader>o', t.oldfiles, { desc = 'Recent files' })
      map('n', '<leader>h', t.help_tags, { desc = 'Search help' })
      map('n', '<leader>/', function()
        t.current_buffer_fuzzy_find { previewer = false }
      end, { desc = 'Search in current buffer' })
    end,
  },

  -- Terminal -----------------------------------------------------------------
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    keys = { [[<C-\>]], '<leader>r', '<leader>t' },
    cmd = { 'ToggleTerm', 'TermExec' },
    config = function()
      require('toggleterm').setup {
        open_mapping = [[<C-\>]],
        size = 15,
        direction = 'horizontal',
        start_in_insert = true,
        persist_size = true,
        shade_terminals = true,
      }

      -- <Esc><Esc> gets you out of terminal insert mode.
      map('t', '<Esc><Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })

      -- <leader>r: run a shell command. The prompt is prefilled with the last
      -- command, so re-running a build is <leader>r<CR>.
      local last = ''
      map('n', '<leader>r', function()
        vim.ui.input({ prompt = 'Run: ', default = last, completion = 'shellcmd' }, function(cmd)
          if not cmd or cmd == '' then
            return
          end
          last = cmd
          vim.cmd 'silent! wall' -- save first; you're compiling
          require('toggleterm').exec(cmd, 1)
        end)
      end, { desc = 'Run command in terminal' })

      map('n', '<leader>t', '<cmd>ToggleTerm direction=float<CR>', { desc = 'Floating terminal' })
    end,
  },

  -- Formatting ---------------------------------------------------------------
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>F',
        function()
          require('conform').format { async = true }
        end,
        desc = 'Format buffer',
      },
    },
    opts = {
      -- Leave this on. Silent failure is how a broken stylish-haskell config
      -- can masquerade as "formatting ran and changed nothing".
      notify_on_error = true,
      format_on_save = { timeout_ms = 1000 },
      formatters_by_ft = {
        haskell = { 'stylish-haskell' },
        lua = { 'stylua' },
      },
    },
  },

  -- Small, zero-config quality-of-life ---------------------------------------
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Extra text objects: va) vi' ci" etc., with better search behaviour.
      require('mini.ai').setup { n_lines = 500 }
      -- Surround: saiw) to wrap a word, sd) to unwrap, sr)] to change.
      require('mini.surround').setup()
      -- Statusline.
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = false }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },
}, {
  ui = {
    icons = {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
  change_detection = { notify = false },
})
