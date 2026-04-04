local lspconfig = require "lspconfig"
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local constants = require "configs.format_const"

local defaults = {
	on_attach = on_attach,
	on_init = on_init,
	capabilities = capabilities,
}

local servers = {
	angularls = {},
	ansiblels = {},
	clangd = {},
	csharp_ls = {},
	cssls = {},
	dockerls = {},
	docker_compose_language_service = {},
	gopls = {},
	helm_ls = {},
	jsonls = {},
	lemminx = {},
	lua_ls = {},
	sqlls = {
		on_attach = function(client, _)
			print(vim.inspect(client.server_capabilities))
		end,
	},
	tailwindcss = {},
	taplo = {},
	terraformls = {},

	bashls = { filetypes = { "sh", "zsh" } },

	ts_ls = {
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = vim.fn.expand "$MASON/packages/vue-language-server/node_modules/@vue/language-server",
					languages = { "javascript", "typescript", "vue" },
				},
			},
		},
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
	},

	volar = {
		cmd = { vim.fn.expand "$MASON/bin/vue-language-server", "--stdio" },
		filetypes = { "vue" },
		init_options = {
			vue = {
				hybridMode = true,
			},
		},
	},

	html = {
		filetypes = { "html", "typescriptreact", "javascriptreact" },
		cmd = { "vscode-html-language-server", "--stdio" },
	},

	pylsp = {
		settings = {
			pylsp = {
				plugins = {
					pycodestyle = {
						ignore = { "W191" },
						maxLineLength = constants.maxLineLength,
					},
				},
			},
		},
	},

	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				assist = {
					importGranularity = "module",
					importPrefix = "by_self",
				},
				cargo = { allFeatures = true },
				checkOnSave = { command = "clippy" },
			},
		},
	},

	yamlls = {
		on_attach = function(client, bufnr)
			if vim.bo[bufnr].filetype == "helm" then
				client.stop()
				return
			end
			on_attach(client, bufnr)
		end,
		filetypes = { "yaml", "yml" },
	},
}

for server_name, config in pairs(servers) do
	local merged = vim.tbl_deep_extend("force", defaults, config)
	lspconfig[server_name].setup(merged)
end

-- Global default border for all LSP float windows
local orig_open_floating = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
	opts = opts or {}
	opts.border = opts.border or "rounded"
	return orig_open_floating(contents, syntax, opts, ...)
end

vim.diagnostic.config {
	float = { border = "rounded" },
}
