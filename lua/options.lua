require "nvchad.options"

local constants = require "configs.format_const"

local function apply_indent()
	local ft = vim.bo.filetype
	local size = (constants.indent_size and constants.indent_size[ft]) or constants.default_indent_size or 4
	local expand_tab = (constants.expand_tabs and constants.expand_tabs[ft]) or constants.default_expand_tabs or false

	vim.bo.shiftwidth = size
	vim.bo.tabstop = size
	vim.bo.expandtab = expand_tab
	vim.opt.textwidth = 0
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = apply_indent,
})
