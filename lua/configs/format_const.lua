local M = {}

M.maxLineLength = tonumber(vim.g.LSP_MAX_LENGTH) or tonumber(vim.env.LSP_MAX_LENGTH) or 120
M.default_expand_tabs = false
M.default_indent_size = tonumber(vim.g.DEFAULT_INDENT_SIZE) or 4

M.indent_size = {
	lua = 2,
	json = 2,
	yaml = 2,
	yml = 2,
	xml = 2,
	css = 2,
	scss = 2,
	html = 2,
	javascript = 2,
	javascriptreact = 2,
	typescript = 2,
	typescriptreact = 2,
	jsx = 2,
	tsx = 2,
	vue = 2,
	helm = 2,
}

M.expand_tabs = {
	python = true,
	yaml = true,
}

return M
