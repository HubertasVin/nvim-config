require "nvchad.options"

-- Fix for broken wl-copy
-- vim.g.clipboard = {
--   name = "wl-clipboard-detached",
--   copy = {
--     ["+"] = { "sh", "-c", "cat | wl-copy --foreground --type text/plain &" },
--     ["*"] = { "sh", "-c", "cat | wl-copy --foreground --primary --type text/plain &" },
--   },
--   paste = {
--     ["+"] = { "wl-paste", "--no-newline", "--type", "text/plain" },
--     ["*"] = { "wl-paste", "--no-newline", "--primary", "--type", "text/plain" },
--   },
--   cache_enabled = 1,
-- }

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
