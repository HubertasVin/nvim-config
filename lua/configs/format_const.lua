local M = {}

-- Desired max line length; can be overridden via :let g:LSP_MAX_WIDTH or env var
M.maxLineLength = tonumber(vim.g.LSP_MAX_LENGTH) or tonumber(vim.env.LSP_MAX_LENGTH) or 120

return M
