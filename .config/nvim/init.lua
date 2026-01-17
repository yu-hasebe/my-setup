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
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
-- Share clipboard with OS
vim.o.clipboard = "unnamedplus"
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
