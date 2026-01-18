local augroup = vim.api.nvim_create_augroup("lua/helpers/auto_command.lua", {})

local function create_autocmd(event, opts)
	vim.api.nvim_create_autocmd(
		event,
		vim.tbl_extend("force", {
			group = augroup,
		}, opts)
	)
end

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
