vim.api.nvim_create_user_command("InitLua", function()
	vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Open init.lua" })

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

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	update_in_insert = false,
})

local augroup = vim.api.nvim_create_augroup("init.lua", {})

local function create_autocmd(event, opts)
	vim.api.nvim_create_autocmd(
		event,
		vim.tbl_extend("force", {
			group = augroup,
		}, opts)
	)
end

-- Type gx to jump this page:
-- https://vim-jp.org/vim-users-jp/2011/02/20/Hack-202.html
create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(event)
		local dir = vim.fs.dirname(event.file)
		local force = vim.v.cmdbang == 1
		local isdirectory = vim.fn.isdirectory(dir) == 0
		if isdirectory and (force or vim.fn.confirm('"' .. dir .. '" does not exist. Create?', "&Yes\n&No") == 1) then
			vim.fn.mkdir(vim.fn.iconv(dir, vim.opt.encoding:get(), vim.opt.termencoding:get()), "p")
		end
	end,
	desc = "Auto mkdir to save files",
})

require("mini.icons").setup()

local function lsp_keymaps(bufnr)
	local opts = { buffer = bufnr, silent = true }
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

	vim.keymap.set("i", "<C-q>", "<C-x><C-o>", opts)
end

-- Go configuration
create_autocmd("FileType", {
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
create_autocmd("FileType", {
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
create_autocmd("FileType", {
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

vim.cmd.colorscheme("kanagawa")
require("mini.icons").setup()
require("mini.statusline").setup()
vim.opt.laststatus = 3
vim.opt.cmdheight = 0

local hipatterns = require("mini.hipatterns")
local hi_words = require("mini.extra").gen_highlighter.words
hipatterns.setup({
	highlighters = {
		-- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
		fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
		hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
		todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
		note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
		-- Highlight hex color strings (`#rrggbb`) using that color
		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
})

-- Why not work?
require("mini.cursorword").setup()

require("mini.indentscope").setup()
require("mini.trailspace").setup()
-- require('mini.sessions').setup()
require("mini.starter").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
local gen_ai_spec = require("mini.extra").gen_ai_spec
require("mini.ai").setup({
	custom_textobjects = {
		B = gen_ai_spec.buffer(),
		D = gen_ai_spec.diagnostic(),
		I = gen_ai_spec.indent(),
		L = gen_ai_spec.line(),
		N = gen_ai_spec.number(),
		J = { { "()%d%d%d%d%-%d%d%-%d%d()", "()%d%d%d%d%/%d%d%/%d%d()" } },
	},
})

local function mode_nx(keys)
	return { mode = "n", keys = keys }, { mode = "x", keys = keys }
end
local clue = require("mini.clue")
clue.setup({
	triggers = {
		-- Leader triggers
		mode_nx("<leader>"),

		-- Built-in completion
		{ mode = "i", keys = "<c-x>" },

		-- `g` key
		mode_nx("g"),

		-- Marks
		mode_nx("'"),
		mode_nx("`"),

		-- Registers
		mode_nx('"'),
		{ mode = "i", keys = "<c-r>" },
		{ mode = "c", keys = "<c-r>" },

		-- Window commands
		{ mode = "n", keys = "<c-w>" },

		-- bracketed commands
		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },

		-- `z` key
		mode_nx("z"),

		-- surround
		mode_nx("s"),

		-- text object
		{ mode = "x", keys = "i" },
		{ mode = "x", keys = "a" },
		{ mode = "o", keys = "i" },
		{ mode = "o", keys = "a" },

		-- option toggle (mini.basics)
		{ mode = "n", keys = "m" },
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

require("mini.fuzzy").setup()
require("mini.completion").setup({
	lsp_completion = {
		process_items = MiniFuzzy.process_lsp_items,
	},
})

-- improve fallback completion
vim.opt.complete = { ".", "w", "k", "b", "u" }
vim.opt.completeopt:append("fuzzy")
vim.opt.dictionary:append("/usr/share/dict/words") -- 注意1

-- define keycodes
local keys = {
	cn = vim.keycode("<c-n>"),
	cp = vim.keycode("<c-p>"),
	ct = vim.keycode("<c-t>"),
	cd = vim.keycode("<c-d>"),
	cr = vim.keycode("<cr>"),
	cy = vim.keycode("<c-y>"),
}

-- select by <tab>/<s-tab>
vim.keymap.set("i", "<tab>", function()
	-- popup is visible -> next item
	-- popup is NOT visible -> add indent
	return vim.fn.pumvisible() == 1 and keys.cn or keys.ct
end, { expr = true, desc = "Select next item if popup is visible" })
vim.keymap.set("i", "<s-tab>", function()
	-- popup is visible -> previous item
	-- popup is NOT visible -> remove indent
	return vim.fn.pumvisible() == 1 and keys.cp or keys.cd
end, { expr = true, desc = "Select previous item if popup is visible" })

-- complete by <cr>
vim.keymap.set("i", "<cr>", function()
	if vim.fn.pumvisible() == 0 then
		-- popup is NOT visible -> insert newline
		return require("mini.pairs").cr() -- 注意2
	end
	local item_selected = vim.fn.complete_info()["selected"] ~= -1
	if item_selected then
		-- popup is visible and item is selected -> complete item
		return keys.cy
	end
	-- popup is visible but item is NOT selected -> hide popup and insert newline
	return keys.cy .. keys.cr
end, { expr = true, desc = "Complete current item if item is selected" })

require("mini.tabline").setup()
require("mini.bufremove").setup()

vim.api.nvim_create_user_command("Bufdelete", function()
	MiniBufremove.delete()
end, { desc = "Remove buffer" })

require("mini.files").setup()

vim.api.nvim_create_user_command("Files", function()
	MiniFiles.open()
end, { desc = "Open file exproler" })

require("mini.pick").setup()
vim.ui.select = MiniPick.ui_select
vim.keymap.set("n", "<space>f", function()
	MiniPick.builtin.files({ tool = "git" })
end, { desc = "mini.pick.files" })

vim.keymap.set("n", "<space>b", function()
	local wipeout_cur = function()
		vim.api.nvim_buf_delete(MiniPick.get_picker_matches().current.bufnr, {})
	end
	local buffer_mappings = { wipeout = { char = "<c-d>", func = wipeout_cur } }
	MiniPick.builtin.buffers({ include_current = false }, { mappings = buffer_mappings })
end, { desc = "mini.pick.buffers" })

require("mini.visits").setup()
vim.keymap.set("n", "<space>h", function()
	require("mini.extra").pickers.visit_paths()
end, { desc = "mini.extra.visit_paths" })

vim.keymap.set("c", "h", function()
	if vim.fn.getcmdtype() .. vim.fn.getcmdline() == ":h" then
		return "<c-u>Pick help<cr>"
	end
	return "h"
end, { expr = true, desc = "mini.pick.help" })

require("mini.diff").setup()

require("mini.git").setup()
vim.keymap.set({ "n", "x" }, "<space>gs", MiniGit.show_at_cursor, { desc = "Show at cursor" })

local map = require("mini.map")
map.setup({
	integrations = {
		map.gen_integration.builtin_search(),
		map.gen_integration.diff(),
		map.gen_integration.diagnostic(),
	},
	symbols = {
		scroll_line = "▶",
	},
})
vim.keymap.set("n", "mmf", MiniMap.toggle_focus, { desc = "MiniMap.toggle_focus" })
vim.keymap.set("n", "mms", MiniMap.toggle_side, { desc = "MiniMap.toggle_side" })
vim.keymap.set("n", "mmt", MiniMap.toggle, { desc = "MiniMap.toggle" })
