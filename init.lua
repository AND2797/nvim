-- =============================================================================
-- Basic Neovim Settings
-- These are fundamental settings for Neovim's behavior and appearance.
-- =============================================================================

-- Set tabstop, shiftwidth, expandtab for consistent indentation.
-- Python typically uses 4 spaces for indentation.
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- Use spaces instead of tabs

-- Enable line numbers and relative line numbers for navigation.
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse support in all modes.
vim.opt.mouse = 'a'

-- Enable case-insensitive searching, but sensitive if uppercase is used.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Set wrap to false to avoid wrapping long lines.
vim.opt.wrap = false

-- Set the default file encoding to UTF-8.
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- Set the leader key (often used for custom keybindings).
-- By default, it's backslash. Space is a popular alternative.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable persistent undo.
vim.opt.undofile = true

-- Highlight the current line.
vim.opt.cursorline = true

-- Add a scroll off value (lines around cursor when scrolling).
vim.opt.scrolloff = 8

-- Set signcolumn to 'yes' to always show the sign column for diagnostics.
vim.opt.signcolumn = 'yes'

-- =============================================================================
-- Lazy.nvim Plugin Manager Setup
-- Lazy.nvim is a fast and easy-to-use plugin manager for Neovim.
-- It automatically installs and manages plugins defined in the 'plugins' table.
-- =============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({"git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- Define the plugins to be installed and configured.
require("lazy").setup({
  -- === Core Development Experience ===
  {
    'neovim/nvim-lspconfig', -- Collection of configurations for Neovim's built-in LSP.
    dependencies = {
      'williamboman/mason.nvim',        -- Plugin to manage LSP servers, DAP servers, linters, and formatters.
      'williamboman/mason-lspconfig.nvim', -- Bridges mason.nvim with nvim-lspconfig.
      'hrsh7th/cmp-nvim-lsp',           -- nvim-cmp source for Neovim's built-in LSP.
      'hrsh7th/nvim-cmp',               -- Auto-completion plugin for Neovim.
      'L3MON4D3/LuaSnip',               -- Snippet engine.
      'saadparwaiz1/cmp_luasnip',       -- nvim-cmp source for LuaSnip.
      'rafamadriz/friendly-snippets',   -- Set of useful snippets.
    },
    config = function()
      -- LSP configuration setup
      local lspconfig = require('lspconfig')
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Define a common on_attach function for LSP servers
      -- This function runs when an LSP client attaches to a buffer
      local on_attach = function(client, bufnr)
        -- Enable completion for the attached client
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Set keymaps for LSP actions
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to Definition', buffer = bufnr })
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = 'Go to Declaration', buffer = bufnr })
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Show References', buffer = bufnr })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to Implementation', buffer = bufnr })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation', buffer = bufnr })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename Symbol', buffer = bufnr })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action', buffer = bufnr })
        vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, { desc = 'Format Document', buffer = bufnr })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic', buffer = bufnr })
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic', buffer = bufnr })
        vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, { desc = 'Workspace Symbols', buffer = bufnr })

        -- You can add more client-specific logic here if needed
      end

      -- Setup for nvim-cmp
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' }, -- LSP completion (code suggestions from language server)
          { name = 'luasnip' },  -- Snippets (e.g., 'for' expands to a for loop structure)
        }, {
          { name = 'buffer' },   -- Completion from current buffer words
        })
      })

      -- Mason setup
      require('mason').setup({
        ensure_installed = { 'ruff', 'lua_ls', 'pyright' }, -- Added 'pyright' for Python language server
      })

      require('mason-lspconfig').setup({
        ensure_installed = {}, -- No servers automatically ensured by mason-lspconfig, handled by handlers below
        handlers = {
          -- Default handler for LSP servers not explicitly configured.
          -- This will be used for 'lua_ls' and any other LSP server Mason installs
          -- that doesn't have a specific handler function here.
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end,
          -- Explicit handler for 'ruff' LSP server (linting/formatting)
          ruff = function()
            lspconfig.ruff.setup({
              capabilities = capabilities,
              on_attach = on_attach, -- Attach common behavior to ruff
              filetypes = { 'python' },
              settings = {
                  args = {
                      '--stdin-filename', '%f',
                      '--fix',
                      '--exit-zero',
                      '--force-exclude',
                      '--isolated',
                      '--respect-gitignore',
                      '--extend-select', 'I', -- Enable auto-fixable import sorting with 'I'
                  },
                  format = {
                      enabled = true
                  },
              },
            })
          end,
          -- Explicit handler for 'pyright' LSP server (semantic completion, definitions)
          pyright = function()
            lspconfig.pyright.setup({
              capabilities = capabilities,
              on_attach = on_attach, -- Attach common behavior to pyright
              filetypes = { 'python' },
              settings = {
                -- You can add specific pyright settings here if needed, e.g.:
                -- python = {
                --   analysis = {
                --     typeCheckingMode = "basic",
                --     autoSearchPaths = true,
                --     use="python",
                --   },
                -- },
              },
            })
          end,
        },
      })
    end
  },

  {
    'nvim-treesitter/nvim-treesitter', -- Enhanced syntax highlighting and structural editing
    build = ':TSUpdate',               -- Command to run after installation
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { 'python', 'lua', 'vim' }, -- Install parsers for these languages
        highlight = {
          enable = true, -- Enable syntax highlighting
        },
        indent = {
          enable = true, -- Enable indentation
        },
      })
    end
  },

  {
    'nvim-telescope/telescope.nvim', -- Fuzzy finder for files, buffers, etc.
    tag = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live Grep (search content)' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find Buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help Tags' })
      vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = 'Show Diagnostics' })
    end
  },

  {
    'nvim-tree/nvim-tree.lua', -- File explorer
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- Required for icons
    },
    config = function()
      require('nvim-tree').setup({
        sort_by = "name", -- Corrected: Changed from 'filetime' to 'name'
        view = {
          width = 30,
          relativenumber = true,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })
      vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle NvimTree' })
    end
  },

  {
    'lukas-reineke/indent-blankline.nvim', -- Indentation guides
    main = 'ibl',
    config = function()
      require('ibl').setup({
        -- For example, disable for certain filetypes
        exclude = {
          filetypes = {
            "help", "terminal", "dashboard", "packer", "gitcommit", "NvimTree", "lazy",
          },
        },
      })
    end
  },

  {
    'nvim-lualine/lualine.nvim', -- Status line
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = 'auto', -- Use a theme, 'auto' tries to pick one based on your colorscheme
          component_separators = { left = '', right = ''},
          section_separators = { left = '', right = ''},
          disabled_filetypes = {
            statusline = {},
            winbar = {},
          },
          ignore_focus = {},
          always_last_line = true,
          globalstatus = true, -- Show statusline always
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {}
        },
        tabline = {},
        extensions = {}
      })
    end
  },

  {
    'akinsho/toggleterm.nvim', -- Integrated terminal
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<C-t>]], -- Keybinding to open/close terminal
        hide_numbers = true,
        direction = 'float', -- 'float' for floating window, 'horizontal' or 'vertical'
        terminal_mappings = true, -- Map normal mode commands to terminal mode
        shell = vim.o.shell,
      })
      -- Create a Python terminal
      vim.keymap.set("n", "<leader>py", "<cmd>ToggleTerm direction=float size=30<CR>", { desc = "Python Terminal" })
      -- Function to execute current Python file in ToggleTerm
      vim.api.nvim_create_user_command('PythonRun', function()
        -- Ensure ToggleTerm is opened
        vim.cmd('ToggleTerm direction=float size=30')
        -- Get current file path
        local file_path = vim.fn.expand('%:p')
        -- Send command to the terminal
        vim.cmd('ToggleTermSendCommand python ' .. vim.fn.shellescape(file_path))
      end, { desc = 'Run Current Python File' })

      vim.keymap.set('n', '<leader>pr', ':PythonRun<CR>', { desc = 'Run Current Python File' })

    end
  },
{
    "lervag/vimtex",
    lazy = false, -- Very important: VimTeX should not be lazy-loaded for best results
    init = function()
      -- VimTeX configuration goes here
      -- This is where you tell it which PDF viewer to use
      vim.g.vimtex_view_method = 'zathura' -- Change to 'skim' or 'general' if needed
      
      -- This sets the 'leader' for VimTeX commands. 
      -- By default it is \, but many people prefer <localleader>
      vim.g.vimtex_mappings_enabled = 1
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 1
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'skim'
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_compiler_method = 'latexmk'
    end
  },
  -- === Optional: Colorscheme ===
  {
    'folke/tokyonight.nvim', -- A popular, aesthetically pleasing colorscheme
    lazy = false,            -- Load this plugin immediately
    priority = 1000,         -- Ensure it loads before other plugins
    config = function()
      -- Use pcall to safely load the colorscheme in Lua
      local status_ok, _ = pcall(vim.cmd.colorscheme, "tokyonight-night")
      if not status_ok then
        vim.notify("Colorscheme tokyonight-night not found!", vim.log.levels.WARN)
        -- Fallback to a default colorscheme if tokyonight-night isn't available
        vim.cmd.colorscheme "default"
      end
    end
  },
}, {})

-- =============================================================================
-- Autocommands (Optional but useful)
-- Automatic commands that run on certain events.
-- =============================================================================

-- Auto-resize NvimTree when window changes
vim.api.nvim_create_autocmd('VimResized', {
  callback = function()
    require('nvim-tree.api').view.sync()
  end,
})

require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})

-- Ensure correct filetype for Python files (though LSP usually handles this)
vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
  pattern = '*.py',
  command = 'set filetype=python',
})

-- Format on save (requires an LSP capable of formatting, like ruff_lsp)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.py',
  callback = function()
    vim.lsp.buf.format { async = true }
  end,
})

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.highlight.on_yank({
      higroup = 'IncSearch',
      timeout = 150,
    })
  end,
})

-- LuaSnip 
require("luasnip").config.set_config({ -- Setting LuaSnip config

  -- Enable autotriggered snippets
  enable_autosnippets = true,

  -- Use Tab (or some other key if you prefer) to trigger visual selection
  store_selection_keys = "<Tab>",
})

-- https://ejmastnak.com/tutorials/vim-latex/luasnip/
vim.cmd[[
"Expand or jump in insert mode
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 

"Jump forward through tabstops in visual mode
smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'
]]

