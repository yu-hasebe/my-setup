
vim.api.nvim_create_user_command(
    'InitLua',
    function()
        vim.cmd.edit(vim.fn.stdpath('config') .. '/init.lua')
    end,
    { desc = 'Open init.lua' }
)

vim.o.encoding = "utf-8"
vim.o.number = true
vim.o.relativenumber = true

-- Indent
vim.o.expandtab = true
vim.o.shiftround = true
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.tabstop = 2

-- Scroll offset
vim.o.scrolloff = 3

-- Move the cursor to the next (previous) line across the last (first) character
vim.o.whichwrap = 'b,s,h,l,<,>,[,],~'

-- Share clipboard with OS
vim.o.clipboard = "unnamedplus"

-- Show cursorline
vim.o.cursorline = true

vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")
vim.cmd("colorscheme desert")

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	update_in_insert = false,
})

local augroup = vim.api.nvim_create_augroup('init.lua', {})

local function create_autocmd(event, opts)
  vim.api.nvim_create_autocmd(event, vim.tbl_extend('force', {
    group = augroup,
  }, opts))
end

-- Type gx to jump this page:
-- https://vim-jp.org/vim-users-jp/2011/02/20/Hack-202.html
create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function(event)
    local dir = vim.fs.dirname(event.file)
    local force = vim.v.cmdbang == 1
    local isdirectory = vim.fn.isdirectory(dir) == 0
    if isdirectory and (force or vim.fn.confirm('"' .. dir .. '" does not exist. Create?', "&Yes\n&No") == 1) then
      vim.fn.mkdir(vim.fn.iconv(dir, vim.opt.encoding:get(), vim.opt.termencoding:get()), 'p')
    end
  end,
  desc = 'Auto mkdir to save files'
})

require("mini.icons").setup()

local function lsp_keymaps(bufnr)
	local opts = { buffer = bufnr, silent = true }
	-- NOTE:
	-- <C-i> next
	-- <C-o> back
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

	vim.keymap.set("i", "<C-q>", "<C-x><C-o>", opts)
end

-- Go configuration
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		vim.lsp.start({
			name = "gopls",
			cmd = { "gopls" },
			root_dir = vim.fs.root(0, { "go.mod", ".git" }),
			settings = {
				gopls = {
					gofumpt = true,
					analyses = { unusedparams = true },
					staticcheck = true,
				},
			},
			on_attach = function(client, bufnr)
				lsp_keymaps(bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ async = false })
					end,
				})
			end,
		})
	end,
})

-- Bash configuration
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sh", "bash", "zsh" },
	callback = function()
		vim.lsp.start({
			name = "bashls",
			cmd = { "bash-language-server", "start" },
			root_dir = vim.fs.root(0, { ".git" }),
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ async = false })
					end,
				})
			end,
			settings = {
				bashIde = {
					globPattern = "*@(.sh|.inc|.bash|.command)",
				},
			},
		})
	end,
})

-- Lua configuration
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua" },
	callback = function()
		vim.lsp.start({
			name = "lua_ls",
			cmd = { "lua-language-server" },
			root_dir = vim.fs.root(0, { ".git" }),

			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						checkThirdParty = false,
						library = vim.api.nvim_get_runtime_file("", true),
					},
					format = {
						enable = false,
					},
				},
			},

			-- FIXME: stylua does not work on save
			on_attach = function(client, bufnr)
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						vim.lsp.buf.format({ async = false })
					end,
				})
			end,
		})
	end,
})

require("config.lazy")

require("mini.icons").setup()
require("mini.statusline").setup()
vim.opt.laststatus = 3
vim.opt.cmdheight = 0

local hipatterns = require('mini.hipatterns')
local hi_words = require('mini.extra').gen_highlighter.words
hipatterns.setup({
  highlighters = {
    -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
    fixme = hi_words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
    hack = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
    todo = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
    note = hi_words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote'),
    -- Highlight hex color strings (`#rrggbb`) using that color
    hex_color = hipatterns.gen_highlighter.hex_color(),
  },
})

-- Why not work?
require('mini.cursorword').setup()

require('mini.indentscope').setup()
require('mini.trailspace').setup()
require('mini.starter').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
local gen_ai_spec = require('mini.extra').gen_ai_spec
require('mini.ai').setup({
  custom_textobjects = {
    B = gen_ai_spec.buffer(),
    D = gen_ai_spec.diagnostic(),
    I = gen_ai_spec.indent(),
    L = gen_ai_spec.line(),
    N = gen_ai_spec.number(),
    J = { { '()%d%d%d%d%-%d%d%-%d%d()', '()%d%d%d%d%/%d%d%/%d%d()' } }
  },
})

local function mode_nx(keys)
  return { mode = 'n', keys = keys }, { mode = 'x', keys = keys }
end
local clue = require('mini.clue')
clue.setup({
  triggers = {
    -- Leader triggers
    mode_nx('<leader>'),

    -- Built-in completion
    { mode = 'i', keys = '<c-x>' },

    -- `g` key
    mode_nx('g'),

    -- Marks
    mode_nx("'"),
    mode_nx('`'),

    -- Registers
    mode_nx('"'),
    { mode = 'i', keys = '<c-r>' },
    { mode = 'c', keys = '<c-r>' },

    -- Window commands
    { mode = 'n', keys = '<c-w>' },

    -- bracketed commands
    { mode = 'n', keys = '[' },
    { mode = 'n', keys = ']' },

    -- `z` key
    mode_nx('z'),

    -- surround
    mode_nx('s'),

    -- text object
    { mode = 'x', keys = 'i' },
    { mode = 'x', keys = 'a' },
    { mode = 'o', keys = 'i' },
    { mode = 'o', keys = 'a' },

    -- option toggle (mini.basics)
    { mode = 'n', keys = 'm' },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers({ show_contents = true }),
    clue.gen_clues.windows({ submode_resize = true, submode_move = true }),
    clue.gen_clues.z(),
  },
})
