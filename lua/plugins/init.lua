return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require "configs.lint"
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"asm",
				"awk",
				"bash",
				"c",
				"c_sharp",
				"cmake",
				"cpp",
				"css",
				"go",
				"haskell",
				"html",
				"json",
				"java",
				"javascript",
				"lua",
				"make",
				"markdown",
				"python",
				"ruby",
				"rust",
				"sql",
				"toml",
				"tsx",
				"typescript",
				"xml",
				"yaml",
				"vim",
				"vimdoc",
				"vue",
			},
		},
		highlight = { enable = true, additional_vim_regex_highlighting = false },
		autotag = { enable = true },
		indent = { enable = true },
	},

	{
		"nvim-java/nvim-java",
		-- dependencies = {
		--   "nvim-java/lua-async-await",
		--   "nvim-java/nvim-java-core",
		--   "nvim-java/nvim-java-test",
		--   "nvim-java/nvim-java-dap",
		--   "MunifTanjim/nui.nvim",
		--   "neovim/nvim-lspconfig",
		--   "mfussenegger/nvim-dap",
		-- },
		ft = { "java" },
		config = function()
			require("java").setup()
		end,
	},

	{
		"stevearc/conform.nvim",
		event = "BufWritePre",
		config = function()
			require "configs.conform"
		end,
	},
	{
		"xzbdmw/colorful-menu.nvim",
		lazy = true,
		main = "colorful-menu",
		opts = {},
	},
	{
		"Saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			{ "Saghen/blink.compat", version = "2.*", opts = {} },
			{ "hrsh7th/cmp-calc", lazy = true },
			{ "folke/lazydev.nvim", ft = "lua", opts = {} },
			{ "xzbdmw/colorful-menu.nvim", main = "colorful-menu", opts = {} },
		},
	},
	{
		"towolf/vim-helm",
		event = { "BufReadPre", "BufNewFile" },
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require "configs.lspconfig"
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		opts = {
			ensure_installed = require "configs.mason_tools",
			auto_update = true,
			run_on_start = false,
			start_delay = 0,
			debounce_hours = 24,
		},
	},

	{
		"smoka7/hop.nvim",
		config = function()
			require("hop").setup()
		end,
		event = "BufRead",
	},

	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("todo-comments").setup {
				keywords = {
					NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				},
				colors = {
					hint = { "Hint", "#FBBF24" },
				},
			}
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
	},
	{
		"roobert/search-replace.nvim",
		config = function()
			require("search-replace").setup {
				default_replace_single_buffer_options = "gcI",
				default_replace_multi_buffer_options = "egcI",
			}
		end,
	},
	{
		"m4xshen/autoclose.nvim",
		config = function()
			require("autoclose").setup {
				options = {
					disabled_filetypes = { "markdown", "text" },
				},
			}
		end,
		event = "InsertEnter",
	},
}
