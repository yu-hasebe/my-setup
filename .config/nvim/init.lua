vim.o.encoding = "utf-8"
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

vim.diagnostic.config({
	virtual_text = true,
	underline = true,
	update_in_insert = false,
})

-- auto complete brackets
vim.api.nvim_set_keymap("i", "(", "()<left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "{", "{}<left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "[", "[]<left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<", "<><left>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "(<Enter>", "(<Enter><Enter>)<up><Tab>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "{<Enter>", "{<Enter><Enter>}<up><Tab>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "[<Enter>", "[<Enter><Enter>]<up><Tab>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<<Enter>", "<<Enter><Enter>><up><Tab>", { noremap = true, silent = true })

-- syntax highlight
vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")

-- color scheme
vim.cmd("colorscheme desert")

local function start_gopls()
	vim.lsp.start({
		name = "gopls",
		cmd = { "gopls" },
		root_dir = vim.fs.dirname(vim.fs.find({ "go.mod", ".git" }, { upward = true })[1]),
		settings = {
			gopls = {
				["formatting.gofumpt"] = true,
			},
		},
	})
end

local function setup_go_format_on_save(bufnr)
	vim.api.nvim_create_autocmd("BufWritePre", {
		buffer = bufnr,
		callback = function()
			local params = vim.lsp.util.make_range_params()
			params.context = { only = { "source.organizeImports" } }

			local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
			for _, res in pairs(result or {}) do
				for _, action in pairs(res.result or {}) do
					if action.edit then
						vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
					elseif action.command then
						vim.lsp.buf.execute_command(action.command)
					end
				end
			end

			vim.lsp.buf.format({ async = false })
		end,
	})
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function()
		start_gopls()
	end,
})

local function start_bashls()
	local root = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1] or vim.loop.cwd())
	vim.lsp.start({
		name = "bashls",
		cmd = { "bash-language-server", "start" },
		root_dir = root,
	})
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "sh,bash",
	callback = function()
		start_bashls()
	end,
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

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		lsp_keymaps(args.buf)

		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client.name == "gopls" then
			setup_go_format_on_save(args.buf)
		end
	end,
})

require("config.lazy")
