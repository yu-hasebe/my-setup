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

vim.api.nvim_set_keymap("i", "(", "()<left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "{", "{}<left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "[", "[]<left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<", "<><left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "(<Enter>", "(<Enter><Enter>)<up><Tab>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "{<Enter>", "{<Enter><Enter>}<up><Tab>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "[<Enter>", "[<Enter><Enter>]<up><Tab>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<<Enter>", "<<Enter><Enter>><up><Tab>", { noremap = true, silent = true })

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
