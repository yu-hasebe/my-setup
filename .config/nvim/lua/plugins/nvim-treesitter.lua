return {
	{
		"nvim-treesitter/nvim-treesitter",
		tag = "v0.10.0",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "go", "lua", "bash" },
				highlight = {
					enable = true,
				},
			})
		end,
	},
}
