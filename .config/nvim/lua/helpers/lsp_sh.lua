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
