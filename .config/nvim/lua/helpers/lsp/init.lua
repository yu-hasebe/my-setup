vim.api.nvim_create_user_command("LspHealth", "checkhealth vim.lsp", { desc = "LSP health check" })

require("helpers.lsp.lua")
require("helpers.lsp.sh")
require("helpers.lsp.go")
