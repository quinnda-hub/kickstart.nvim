-- Haskell: let the compiler be the error checker.
--
-- :make (or <leader>m) builds and drops GHC's errors into the quickfix list,
-- so ]q / [q walk you through them with the cursor landing on the right
-- line and column. No language server involved.

local buf = vim.api.nvim_get_current_buf()

-- Walk up from this file looking for a project marker.
-- Returns the project directory and which build tool owns it.
local function project()
  local name = vim.api.nvim_buf_get_name(buf)
  local start = name ~= '' and vim.fs.dirname(name) or vim.fn.getcwd()

  local hits = vim.fs.find(function(file)
    return file == 'stack.yaml' or file == 'cabal.project' or file:match '%.cabal$'
  end, { path = start, upward = true, type = 'file', limit = math.huge })

  if #hits == 0 then
    return nil, nil
  end

  local dir = vim.fs.dirname(hits[1])
  for _, hit in ipairs(hits) do
    if vim.fs.basename(hit) == 'stack.yaml' then
      return vim.fs.dirname(hit), 'stack'
    end
  end
  return dir, 'cabal'
end

local root, tool = project()

if tool == 'stack' then
  vim.bo.makeprg = 'stack build --fast'
elseif tool == 'cabal' then
  vim.bo.makeprg = 'cabal build all'
else
  -- Loose file: typecheck only. No .o/.hi droppings, much faster than a link.
  vim.bo.makeprg = 'ghc -fno-code -Wall %'
end

-- Matched against real GHC 9.4 and 9.6 output: plain errors, `[GHC-NNNNN]`
-- coded errors, multi-line `(l,c)-(l,c)` spans, and warnings. The trailing
-- discard rules throw away cabal's preamble and the ` | ^^^^` source excerpts.
vim.bo.errorformat = table.concat({
  [[%-G[%.%#]%.%#]],
  [[%-G%\s%#]],
  [[%E%f:%l:%c: error:%m]],
  [[%W%f:%l:%c: warning:%m]],
  [[%E%f:%l:%c: error:]],
  [[%W%f:%l:%c: warning:]],
  [[%E%f:(%l\,%c)-(%*\d\,%*\d): error:%m]],
  [[%W%f:(%l\,%c)-(%*\d\,%*\d): warning:%m]],
  [[%E%f:(%l\,%c)-(%*\d\,%*\d): error:]],
  [[%W%f:(%l\,%c)-(%*\d\,%*\d): warning:]],
  [[%-G%\s%#|%.%#]],
  [[%-G%\d%\+\ |%.%#]],
  [[%C%\s%\+%m]],
  [[%-G%.%#]],
}, ',')

-- Build. Runs from the project root so the paths GHC prints resolve, then
-- restores your working directory. Quickfix opens only if something is wrong.
vim.keymap.set('n', '<leader>m', function()
  local restore = nil
  if root and root ~= vim.fn.getcwd() then
    restore = vim.fn.getcwd()
    vim.cmd('lcd ' .. vim.fn.fnameescape(root))
  end

  vim.cmd 'silent! wall'
  vim.cmd 'silent! make'

  if restore then
    vim.cmd('lcd ' .. vim.fn.fnameescape(restore))
  end

  local items = vim.fn.getqflist()
  if #items > 0 then
    vim.cmd 'copen'
    vim.cmd 'cfirst'
  else
    vim.cmd 'cclose'
    vim.notify('Build OK', vim.log.levels.INFO)
  end
end, { buffer = buf, desc = 'Haskell: build into quickfix' })

-- ghci, in the terminal split, pointed at the right thing.
vim.keymap.set('n', '<leader>i', function()
  local cmd
  if tool == 'stack' then
    cmd = 'stack ghci'
  elseif tool == 'cabal' then
    cmd = 'cabal repl'
  else
    cmd = 'ghci ' .. vim.fn.shellescape(vim.fn.expand '%')
  end

  vim.cmd 'silent! wall'
  require('toggleterm').exec(cmd, 2, nil, root)
end, { buffer = buf, desc = 'Haskell: ghci' })

-- Haskell is laid out in 2-space indents by near-universal convention.
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
