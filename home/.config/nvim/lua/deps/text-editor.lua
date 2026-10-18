local keymap = require('keymap')
local nnoremap = keymap.nnoremap
local tnoremap = keymap.tnoremap
local vnoremap = keymap.vnoremap

local plugins = {
  { -- Useful plugin to show you pending keybinds.
    -- Also load-bearing for leader sequences: without it, a pause longer than
    -- timeoutlen (300ms) after <space> aborts the leader map and e.g. yfr
    -- becomes yank-to-find-r, clobbering the clipboard. which-key waits.
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function()
      require('which-key').setup()
    end,
  },

 { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for install instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

      'nvim-telescope/telescope-live-grep-args.nvim',

      'onsails/lspkind-nvim',
    },
    config = function()
      -- The easiest way to use telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of help_tags options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      require('telescope').setup {
        defaults = {
          file_ignore_patterns = { "deps", "_build", ".elixir_ls"},
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--ignore-vcs',
            '--ignore-file',
            '.gitignore',
          },

          mappings = {
            i ={
              ["<C-w>"] = function(prompt_bufnr)
                require("telescope.actions").smart_send_to_qflist(prompt_bufnr)
              end,

              ["<C-e>"] = function(prompt_bufnr)
                require("telescope.actions").smart_add_to_qflist(prompt_bufnr)
              end,
              ["<C-Down>"] = function(prompt_bufnr)
                require('telescope.actions').cycle_history_next(prompt_bufnr)
              end,

              ["<C-Up>"] = function(prompt_bufnr)
                require('telescope.actions').cycle_history_prev(prompt_bufnr)
              end,
            },
          },
        },
        extensions = {
          ['ui-select'] = {
           require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable telescope extensions, if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      nnoremap('<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      nnoremap('<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

      -- - vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      nnoremap('<leader>sf', '<cmd>lua require("telescope.builtin").find_files({ hidden = true })<CR>', { noremap = true, desc = '[S]earch [F]iles' })


      nnoremap('<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      nnoremap('<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      -- nnoremap('<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      nnoremap("<leader>sg", function() require('telescope').extensions.live_grep_args.live_grep_args() end, { desc = '[S]earch by [G]rep' } )
      nnoremap('<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      nnoremap('<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      nnoremap('<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      nnoremap('<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      nnoremap('<leader>qf', builtin.quickfix, { desc = 'quickfix' })
      nnoremap('<leader>qh', builtin.quickfixhistory, { desc = 'quickfix history' })
      nnoremap('<leader>qn', function() vim.api.nvim_command('cnext')  end, { desc = 'quickfix next' })
      nnoremap('<leader>qb', function() vim.api.nvim_command('cprev')  end, { desc = 'quickfix prev' })

      -- { "<leader>qn", function() vim.api.nvim_command('cnext')  end, desc = "quickfix next" },
      -- { "<leader>qb", function() vim.api.nvim_command('cprev')  end, desc = "quickfix prev" },

      -- Slightly advanced example of overriding default behavior and theme
      nnoremap('<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- Also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}

local base = require('deps/base');

for _, plugin in ipairs(base) do
  table.insert(plugins, plugin)
end

return plugins

