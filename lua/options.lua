require "nvchad.options"

local constants = require "configs.format_const"

local function apply_indent()
  local ft = vim.bo.filetype
  local size = (constants.indent_size and constants.indent_size[ft]) or constants.default_indent_size or 4
  local use_tabs = (constants.use_tabs and constants.use_tabs[ft]) or constants.default_use_tabs or false

  vim.bo.shiftwidth = size
  vim.bo.tabstop = size
  vim.bo.expandtab = use_tabs
	vim.opt.textwidth = 0
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = apply_indent,
})
