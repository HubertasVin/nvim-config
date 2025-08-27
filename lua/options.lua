require "nvchad.options"

local constants = require "configs.format_const"

local function apply_indent()
  local ft = vim.bo.filetype
  local size = (constants.indent_size and constants.indent_size[ft]) or constants.default_indent_size or 4
  vim.bo.shiftwidth = size
  vim.bo.tabstop = size
  vim.bo.expandtab = not constants.use_tabs
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = apply_indent,
})
