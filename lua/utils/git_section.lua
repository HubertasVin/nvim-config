local M = {}

local gs = require "gitsigns"

function M.reset_current_line()
  local ln = vim.api.nvim_win_get_cursor(0)[1]
  gs.reset_hunk { ln, ln }
end

function M.reset_selected_lines()
  local s = vim.fn.line "v"
  local e = vim.fn.line "."
  if s > e then
    s, e = e, s
  end
  gs.reset_hunk { s, e }
end

return M
