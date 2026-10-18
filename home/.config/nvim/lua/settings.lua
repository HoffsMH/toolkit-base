local keymap = require('keymap')
local nnoremap = keymap.nnoremap
local tnoremap = keymap.tnoremap
local vnoremap = keymap.vnoremap

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true
--
vim.opt.eol = false
vim.opt.fixeol = false
vim.opt.fixendofline = false
vim.opt.swapfile = false

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

vim.opt.showmode = false

vim.opt.clipboard = 'unnamedplus'
-- OSC 52 provider: yanks follow the terminal you're attached to, not the host.
require('config.remote_clipboard').setup()

-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
--
vim.opt.foldmethod = "indent"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 4

-- Enable break indent
vim.opt.breakindent = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Warn at 80 characters: the marker sits in column 81, so text touching it
-- has already gone over. Purely visual -- no textwidth, so nothing auto-wraps.
vim.opt.colorcolumn = '81'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

-- Autosave on change, but only for normal, named, writable buffers so an
-- unwritable file doesn't error on every keystroke and block typing.
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = "*",
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name == "" then return end
    if vim.bo[args.buf].buftype ~= "" then return end
    if not vim.bo[args.buf].modifiable or vim.bo[args.buf].readonly then return end
    if vim.fn.filewritable(name) ~= 1 then return end
    vim.cmd("silent! write")
  end,
})

nnoremap("<M-w>L", "<cmd>vs<cr>")
nnoremap("<M-w>J", "<cmd>sp<cr>")

nnoremap("<M-w>h", "<C-w>h")
nnoremap("<M-w>j", "<C-w>j")
nnoremap("<M-w>k", "<C-w>k")
nnoremap("<M-w>l", "<C-w>l")

-- yf will copy the path of the current file
nnoremap("<leader>yfr", "<cmd>:let @+=expand('%')<CR>")
nnoremap("<leader>yfa", "<cmd>:let @+=expand('%:p')<CR>")

-- fat thumb
nnoremap("q:", "<Nop>")

nnoremap("<M-d>", "<C-d>")
vnoremap("<M-d>", "<C-d>")

nnoremap("<M-u>", "<C-u>")
vnoremap("<M-u>", "<C-u>")

-- edit current directory
nnoremap("<leader>e.", "<cmd>e %:h<CR>")

nnoremap('<Esc>', '<cmd>nohlsearch<CR>')
nnoremap('<M-e>', 'viw')
nnoremap('<leader>n', '<cmd>e #<cr>', { desc = 'goto last buffer' })

nnoremap('[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
nnoremap(']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
nnoremap('<leader>ed', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
nnoremap('<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

nnoremap('<leader>fd', ':!open %:p:h<CR>', { desc = "Open file explorer in current buffer's directory" })
nnoremap('<leader>fe', ':e %:p:h<CR>', { desc = "Open file explorer in current buffer's directory" })

nnoremap('<leader>b', '<cmd>:bufdo bwipeout<CR>', { desc = 'wipe out all current buffers (after checking out a different branch for instance)' })

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.tabstop = 2      -- Number of visual spaces per TAB
    vim.opt_local.shiftwidth = 2   -- Number of spaces to use for each step of (auto)indent
    vim.opt_local.expandtab = true -- Use spaces instead of tabs
  end,
})

vim.api.nvim_set_option("tabstop", 2)
vim.api.nvim_set_option("shiftwidth", 2)
vim.api.nvim_set_option("softtabstop", 2)

vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = { "*" },
})
