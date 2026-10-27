# nvim

Vim, plus the handful of things worth a plugin. No LSP, no completion engine,
no diagnostics — GHC and ghci report errors, and `:make` pulls them into the
quickfix list.

Leader is `<Space>`.

## Files and buffers

| Key | Does |
| --- | --- |
| `<leader>f` | Find file |
| `<leader>b` | Find open buffer |
| `<leader>g` | Grep the project |
| `<leader>*` | Grep the word under the cursor |
| `<leader>o` | Recent files |
| `<leader>/` | Fuzzy search in this buffer |
| `<leader>h` | Search `:help` |
| `<Tab>` / `<S-Tab>` | Next / previous buffer (`]b` / `[b` do the same) |
| `<leader>1`…`<leader>9` | Jump to that numbered tab |
| `<leader>x` | Close buffer, keep the window layout |

## Windows

| Key | Does |
| --- | --- |
| `<C-h/j/k/l>` | Move between windows |
| `<leader>v` | Vertical split |
| `<leader>s` | Horizontal split |

## Terminal and building

| Key | Does |
| --- | --- |
| `<C-\>` | Toggle the terminal split |
| `<leader>t` | Floating terminal |
| `<leader>r` | Run a shell command. Prefilled with the last one, so re-running a build is `<leader>r<CR>`. Saves all buffers first. |
| `<Esc><Esc>` | Leave terminal insert mode |

## Errors, the vim way

In a Haskell buffer, `<leader>m` saves everything, builds from the project
root, and loads GHC's errors into the quickfix list. The quickfix window only
opens if something is wrong.

| Key | Does |
| --- | --- |
| `<leader>m` | Build into quickfix |
| `]q` / `[q` | Next / previous error |
| `<leader>q` | Toggle the quickfix window |
| `<leader>i` | ghci (`cabal repl`, `stack ghci`, or plain `ghci <file>`) |

`makeprg` is picked per project: `stack build --fast` if there's a `stack.yaml`,
`cabal build all` if there's a `.cabal` or `cabal.project`, otherwise
`ghc -fno-code -Wall %` to typecheck a loose file without emitting artifacts.

## Formatting

Format on save, plus `<leader>F` to do it by hand.

- Haskell: `stylish-haskell` (configured in `~/.config/stylish-haskell/config.yaml`)
- Lua: `stylua` (configured in `.stylua.toml`)

`stylish-haskell` is a tidier, not a full reformatter: it sorts and aligns
imports, formats `LANGUAGE` pragmas and records, and strips trailing
whitespace, but it leaves your expression layout alone. If you want the
opinionated whole-file kind, swap in `ormolu` or `fourmolu` in `init.lua`.

## Editing

`nvim-autopairs` closes brackets and quotes as you open them.

From `mini.nvim`:

- `mini.ai` — better `vi(`, `ca"`, and friends
- `mini.surround` — `saiw)` to wrap a word, `sd)` to unwrap, `sr)]` to change

Completion is vim's built-in insert-mode completion: `<C-n>` / `<C-p>` for
words in open buffers, `<C-x><C-f>` for filenames, `<C-x><C-l>` for whole lines.

## Plugins

Twelve, managed by `lazy.nvim`:

rose-pine, vim-sleuth, nvim-treesitter, nvim-autopairs, bufferline.nvim,
nvim-web-devicons, telescope.nvim, plenary.nvim, telescope-fzf-native.nvim,
toggleterm.nvim, conform.nvim, mini.nvim.

`:Lazy` to manage them. `:checkhealth` if something looks wrong.
