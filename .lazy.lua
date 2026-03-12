return {
	"noirbizarre/ensure.nvim",
	dependencies = {
		"mason-org/mason.nvim", -- Required for tool installation
		-- Optional integrations:
		"nvim-treesitter/nvim-treesitter",
		"stevearc/conform.nvim",
		"mfussenegger/nvim-lint",
	},
	opts = {
		-- LSP servers
		lsp = {
			-- enable = { "lua_ls", "ty" },
		},
		-- Formatters (by filetype)
		formatters = {
			nix = { "nixfmt" },
		},
		-- Linters (by filetype)
	},
}
