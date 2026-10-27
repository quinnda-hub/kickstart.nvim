# nvim

Vim, plus the handful of things worth a plugin. No LSP, no completion engine,
no diagnostics, no build commands baked into the config — you open a terminal
and type what you want.

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

## Terminal

| Key | Does |
| --- | --- |
| `<C-\>` | Toggle the terminal split. Works from normal, insert and terminal mode. |
| `2<C-\>` | Second terminal. Any count gets you another one. |
| `<leader>t` | Floating terminal |
| `<leader>r` | Prompt for a command, run it in the terminal. Saves all buffers first, and the prompt is prefilled with the last command — so a rebuild is `<leader>r<CR>`. |
| `<Esc><Esc>` | Leave terminal insert mode |

The terminal keeps its shell between toggles, so history and working directory
survive. Nothing in this config knows how to build anything; `gcc`, `cabal`,
`make`, `ghci` are things you type.

## Quickfix

Generic vim. Nothing populates it automatically, but `:grep`, `:vimgrep` and
telescope (`<C-q>` from a picker) all do.

| Key | Does |
| --- | --- |
| `]q` / `[q` | Next / previous item |
| `<leader>q` | Toggle the quickfix window |

## Formatting

Format on save, plus `<leader>F` to do it by hand.

| Filetype | Formatter | Config |
| --- | --- | --- |
| C / C++ | `clang-format` | LLVM style by default; drop a `.clang-format` in the project root to change it |
| Haskell | `stylish-haskell` | `~/.config/stylish-haskell/config.yaml` |
| Lua | `stylua` | `.stylua.toml` |

`clang-format --style=GNU --dump-config > .clang-format` is the quickest way to
start from a named style and edit from there.

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

Indentation follows the file you're editing (`vim-sleuth`). Haskell defaults to
2 spaces for new files; that's the only filetype-specific setting in here.

## Plugins

Twelve, managed by `lazy.nvim`:

rose-pine, vim-sleuth, nvim-treesitter, nvim-autopairs, bufferline.nvim,
nvim-web-devicons, telescope.nvim, plenary.nvim, telescope-fzf-native.nvim,
toggleterm.nvim, conform.nvim, mini.nvim.

`:Lazy` to manage them. `:checkhealth` if something looks wrong.
`:messages` for errors that scrolled past.
