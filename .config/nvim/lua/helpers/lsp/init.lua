vim.api.nvim_create_user_command("LspHealth", "checkhealth vim.lsp", { desc = "LSP health check" })

local dirname = vim.fn.stdpath('config') .. '/lua/helpers/lsp'

for file, ftype in vim.fs.dir(dirname) do
  if ftype == 'file' and vim.endswith(file, '.lua') and file ~= 'init.lua' then
    local name = file:sub(1, -5)
    local ok, result = pcall(require, 'helpers.lsp.' .. name)
    if not ok then
      vim.notify('Error loading LSP: ' .. name .. '\n' .. result, vim.log.levels.WARN)
    end
  end
end
