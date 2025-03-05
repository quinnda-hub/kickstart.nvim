local ht = require 'haskell-tools'
local bufnr = vim.api.nvim_get_current_buf()
local opts = { noremap = true, silent = true, buffer = bufnr }

-- CodeLens (for running code lenses from HLS)
vim.keymap.set('n', '<space>cl', vim.lsp.codelens.run, opts)

-- Hoogle search for the type signature under the cursor
vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature, opts)

-- Toggle a GHCi REPL
vim.keymap.set('n', '<leader>rr', ht.repl.toggle, opts)
vim.keymap.set('n', '<leader>rf', function()
  ht.repl.toggle(vim.api.nvim_buf_get_name(0))
end, opts)
vim.keymap.set('n', '<leader>rq', ht.repl.quit, opts)

-- Show available quick fixes
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { noremap = true, silent = true })

-- Hoogle search
vim.keymap.set('n', '<space>hs', require('haskell-tools').hoogle.hoogle_signature, { noremap = true, silent = true })

-- Hover info
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true })
