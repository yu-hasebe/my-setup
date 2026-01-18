vim.api.nvim_create_user_command("LspHealth", "checkhealth vim.lsp", { desc = "LSP health check" })

require("helpers.lsp_lua")
require("helpers.lsp_sh")
require("helpers.lsp_go")
