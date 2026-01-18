local augroup = vim.api.nvim_create_augroup("init.lua", {})

function create_autocmd(event, opts)
	vim.api.nvim_create_autocmd(
		event,
		vim.tbl_extend("force", {
			group = augroup,
		}, opts)
	)
end

return {
	create_autocmd = create_autocmd,
}
