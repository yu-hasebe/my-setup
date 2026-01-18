require("helpers.user_command")
require("helpers.auto_command")
require("helpers.lazy")
require("helpers.mini")
require("helpers.lsp")

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
vim.o.whichwrap = "b,s,h,l,<,>,[,],~"

-- Share clipboard with OS
vim.o.clipboard = "unnamedplus"

-- Show cursorline
vim.o.cursorline = true

vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

vim.cmd.colorscheme("kanagawa")
vim.opt.laststatus = 3
vim.opt.cmdheight = 0

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	update_in_insert = false,
})

