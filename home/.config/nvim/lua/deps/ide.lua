
local plugins = {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      view_options = {
        show_hidden = true
      }
    },

    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
  },
  {
    'andymass/vim-matchup',
    init = function()
      vim.g.matchup_treesitter_enabled = 0
    end,
  },
  {
    'windwp/nvim-autopairs',
    opts = {}
  },
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>as", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    },
  },
  'onsails/lspkind-nvim',
  {
    'glacambre/firenvim',

    -- Lazy load firenvim
    -- Explanation: https://github.com/folke/lazy.nvim/discussions/463#discussioncomment-4819297
    lazy = not vim.g.started_by_firenvim,
    build = function()
        vim.fn["firenvim#install"](0)
    end,
    
    config = function()
      vim.g.firenvim_config = {
        globalSettings = {
          alt = 'all',
        },
        localSettings = {
          ['.*'] = {
            cmdline = 'neovim',
            content = 'text',
            priority = 0,
            selector = 'textarea',
            takeover = 'never',
          },
        },
      }
    end
},
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
    keys = {
      { "<leader>gb", function() require("gitsigns").blame_line{ full=true } end, desc = "blame line" },
      { "<leader>gbl", function() require("gitsigns").toggle_current_line_blame{ full=true } end, desc = "blame line" },
      { "<leader>gl", function() require("gitsigns").toggle_current_line_blame{ full=true } end, desc = "blame line" },
    },
  },

  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

  -- NOTE: Plugins can also be configured to run lua code when they are loaded.
  --
  -- This is often very useful to both group configuration, as well as handle
  -- lazy loading plugins that don't need to be loaded immediately at startup.
  --
  -- For example, in the following configuration, we use:
  --  event = 'VimEnter'
  --
  -- which loads which-key before all the UI elements are loaded. Events can be
  -- normal autocommands events (`:help autocmd-events`).
  --
  -- Then, because we use the `config` key, the configuration only runs
  -- after the plugin has been loaded:
  --  config = function() ... end

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()
    end,
  },

  {
    "chrisgrieser/nvim-early-retirement",
    config = {
      minimumBufferNum = 20,
    },
    event = "VeryLazy",
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      messages = {
        enabled = false, -- enables the Noice messages UI
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      { "rcarriga/nvim-notify", opts = { background_colour = "#000000" } },
      }
  },

  {
    'mbbill/undotree',
    keys = {
      { "<leader>u", function() vim.api.nvim_command("UndotreeToggle") end, desc = "undotree" },
    }
  },

  { -- LSP: nvim-lspconfig 2.x is now a thin shim providing default per-server
    -- configs. Per-server overrides go through vim.lsp.config() (nvim 0.11+).
    -- mason-lspconfig 2.x auto-enables installed servers via vim.lsp.enable().
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim',           opts = {} },
      { 'mason-org/mason-lspconfig.nvim', opts = {} },
      { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
      { 'j-hui/fidget.nvim',              opts = {} },  -- LSP progress UI
    },
    config = function()
      -- Buffer-local keymaps applied each time an LSP attaches.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('user-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          local tb = require('telescope.builtin')
          map('gd',          tb.lsp_definitions,                '[G]oto [D]efinition')
          map('gI',          tb.lsp_implementations,            '[G]oto [I]mplementation')
          map('<leader>D',   tb.lsp_type_definitions,           'Type [D]efinition')
          map('<leader>ds',  tb.lsp_document_symbols,           '[D]ocument [S]ymbols')
          map('<leader>ws',  tb.lsp_dynamic_workspace_symbols,  '[W]orkspace [S]ymbols')
          map('<leader>rn',  vim.lsp.buf.rename,                '[R]e[n]ame')
          map('<leader>ca',  vim.lsp.buf.code_action,           '[C]ode [A]ction')
          map('K',           vim.lsp.buf.hover,                 'Hover Documentation')

          -- Highlight references of the symbol under cursor while idle.
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf, callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- Capabilities boost for completion (blink.cmp adds a bunch).
      local capabilities = vim.tbl_deep_extend(
        'force',
        vim.lsp.protocol.make_client_capabilities(),
        require('blink.cmp').get_lsp_capabilities()
      )
      vim.lsp.config('*', { capabilities = capabilities })

      -- Per-server config overrides (defaults from nvim-lspconfig are fine for
      -- the rest). Add an entry here when a server needs custom settings.
      vim.lsp.config('lua_ls', {
        settings = { Lua = { completion = { callSnippet = 'Replace' } } },
      })

      -- Servers we want auto-installed and auto-enabled. mason-lspconfig
      -- translates these names to Mason package names internally.
      local ensure_installed = {
        'elixirls', 'ruby_lsp', 'ts_ls', 'pyright',
        'rust_analyzer', 'bashls', 'yamlls', 'jsonls',
        'marksman', 'html', 'cssls', 'lua_ls',
      }
      if vim.fn.executable('go') == 1 then
        table.insert(ensure_installed, 'gopls')
      end
      require('mason-lspconfig').setup {
        ensure_installed = ensure_installed,
        -- automatic_enable = true (default) -- calls vim.lsp.enable() per server
      }

      -- Non-LSP tools (formatters, linters, etc.) -- Mason package names.
      require('mason-tool-installer').setup {
        ensure_installed = { 'stylua' },
      }
    end,
  },


  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  {
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = 'rafamadriz/friendly-snippets',

    -- use a release tag to download pre-built binaries
    version = '*',
    -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
    -- build = 'cargo build --release',
    -- If you use nix, you can build from source using latest nightly rust with:
    -- build = 'nix run .#build-plugin',

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- See the full "keymap" documentation for information on defining your own keymap.
      keymap = {
        preset = 'default',
        ['<c-y>'] = { 'select_and_accept' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
      },

      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono'
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
    opts_extend = { "sources.default" }
  },

  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- require('mini.jump').setup({
      --   -- Module mappings. Use `''` (empty string) to disable one.
      --   mappings = {
      --     forward = 'f',
      --     backward = 'F',
      --     forward_till = 't',
      --     backward_till = 'T',
      --     repeat_jump = ';',
      --   },
      --
      --   -- Delay values (in ms) for different functionalities. Set any of them to
      --   -- a very big number (like 10^7) to virtually disable.
      --   delay = {
      --     -- Delay between jump and highlighting all possible jumps
      --     highlight = 250,
      --
      --     -- Delay between jump and automatic stop if idle (no jump is done)
      --     idle_stop = 10000000,
      --   },
      -- })

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      -- install() is async and idempotent, so it's safe on every startup.
      require('nvim-treesitter').install {
        'bash', 'c', 'cpp', 'css', 'diff', 'dockerfile',
        'embedded_template', 'git_config', 'git_rebase', 'gitcommit', 'gitignore',
        'glimmer', 'go', 'gomod', 'gosum',
        'html', 'javascript', 'jsdoc', 'json',
        'lua', 'luadoc', 'make', 'markdown', 'markdown_inline',
        'query', 'regex', 'ruby', 'scss', 'sql', 'toml',
        'tsx', 'typescript', 'vim', 'vimdoc', 'yaml',
      }

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('user-ts-start', { clear = true }),
        callback = function(args)
          local ft = vim.bo[args.buf].filetype
          local lang = vim.treesitter.language.get_lang(ft) or ft
          if lang ~= '' then
            pcall(vim.treesitter.start, args.buf, lang)
          end
        end,
      })
    end,
  },

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- put them in the right spots if you want.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for kickstart
  --
  --  Here are some example plugins that I've included in the kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  -- { import = 'custom.plugins' },
}

local textEditor = require('deps/text-editor');

for _, plugin in ipairs(textEditor) do
  table.insert(plugins, plugin)
end

return plugins
