local augroup = vim.api.nvim_create_augroup("lsp.lua", {})

vim.api.nvim_create_autocmd("LspAttach", {
	group = augroup,
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

		vim.keymap.set("n", "grd", function()
			vim.lsp.buf.definition()
		end, { buffer = args.buf, desc = "vim.lsp.buf.definition()" })

		vim.keymap.set("n", "<space>i", function()
			vim.lsp.buf.format({ bufnr = args.buf, id = client.id })
		end, { buffer = args.buf, desc = "Format buffer" })
	end,
})

vim.lsp.config("*", {
	root_markers = { ".git" },
})

local lua_opts = require("helpers.lsp_lua")
vim.lsp.config("lua", lua_opts)
vim.lsp.enable("lua")

local sh_opts = require("helpers.lsp_sh")
vim.lsp.config("sh", sh_opts)
vim.lsp.enable("sh")

local go_opts = require("helpers.lsp_go")
vim.lsp.config("go", go_opts)
vim.lsp.enable("go")
