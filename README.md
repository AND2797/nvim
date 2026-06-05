# Neovim Config

Single-file config (`init.lua`) using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager.
Everything self-bootstraps on first launch: lazy.nvim clones itself, plugins install,
mason downloads the LSP servers, and treesitter compiles its parsers.

## Setup on a new machine

```bash
git clone git@github.com:AND2797/nvim.git ~/.config/nvim
nvim   # first launch takes a couple of minutes while everything installs
```

`lazy-lock.json` pins every plugin to an exact commit, so a fresh install gets the
same versions as the last machine. Run `:Lazy update` to move the pins forward
(and commit the updated lock file).

## External dependencies

These do not travel with the repo and must be installed first:

| Dependency | Needed for | Install (macOS) |
|---|---|---|
| Neovim ≥ 0.11 | mason-lspconfig v2 / `vim.lsp.config` API | `brew install neovim` |
| ripgrep | Telescope live grep (`<leader>fg`) | `brew install ripgrep` |
| Xcode CLT (`make`/`cc`) | telescope-fzf-native build, treesitter parsers | `xcode-select --install` |
| .NET SDK | omnisharp (C# LSP) | `brew install --cask dotnet-sdk` |
| Node.js | pyright (Python LSP) | `brew install node` |
| A [Nerd Font](https://www.nerdfonts.com/) | nvim-tree / lualine icons | install font, set it in your terminal |
| Skim + latexmk | vimtex PDF preview / compilation (LaTeX only) | `brew install --cask skim`, `brew install --cask mactex-no-gui` |

One-liner for the essentials:

```bash
brew install neovim ripgrep node && brew install --cask dotnet-sdk
```

## Windows (Git Bash) notes

Neovim on Windows reads its config from `%LOCALAPPDATA%\nvim`, **not** `~/.config/nvim`
(even under Git Bash), so clone there:

```bash
git clone git@github.com:AND2797/nvim.git ~/AppData/Local/nvim
```

Dependencies via winget:

```powershell
winget install Neovim.Neovim BurntSushi.ripgrep.MSVC OpenJS.NodeJS Microsoft.DotNet.SDK.8 Kitware.CMake zig.zig
```

- **C compiler**: treesitter needs one to compile parsers; `zig` (above) is the
  easiest, or install MSVC Build Tools / MinGW instead.
- **fzf-native** builds with cmake on Windows automatically (handled in `init.lua`).
- **Nerd Font**: install one and set it in Windows Terminal's profile settings.
- **vimtex**: the Skim viewer config is macOS-only; ignore unless you set up
  LaTeX separately on Windows (e.g. SumatraPDF + MiKTeX).
- **Terminal shell**: `<C-t>` (toggleterm) uses Neovim's default shell, which is
  `cmd.exe` on Windows. To get Git Bash instead, add this to `init.lua`:

  ```lua
  if vim.fn.has('win32') == 1 then
    vim.o.shell = 'bash.exe'  -- Git Bash (must be on PATH)
    vim.o.shellcmdflag = '-c'
    vim.o.shellxquote = ''
  end
  ```

## After first launch

- `:checkhealth` — verify everything is wired up
- `:Mason` — check LSP server installs (ruff, pyright, lua_ls, omnisharp)
- `:Lazy` — plugin status

## Language servers

Configured in `init.lua` via mason-lspconfig (auto-installed and auto-enabled):

- **pyright** + **ruff** — Python (completion/navigation + linting/formatting, format on save)
- **omnisharp** — C# (open a file inside a project with a `.csproj` for it to attach; first index takes ~15s)
- **lua_ls** — Lua

## Key bindings (leader = space)

| Keys | Action |
|---|---|
| `<leader>ff` / `fg` / `fb` / `fd` | Find files / live grep / buffers / diagnostics (Telescope) |
| `gd` / `gr` / `gi` / `gD` | Definition / references / implementations / declaration |
| `K` | Hover docs |
| `<leader>rn` / `<leader>ca` / `<leader>f` | Rename / code action / format |
| `<leader>d`, `]d` / `[d` | Line diagnostics float, next/prev diagnostic |
| `<leader>cs` | Switch colorscheme with live preview |
| `<leader>e` | File tree |
| `<leader>u` | Undotree |
| `<leader>gp` / `<leader>gb`, `]h` / `[h` | Git hunk preview / blame, next/prev hunk |
| `<C-t>` | Floating terminal |
