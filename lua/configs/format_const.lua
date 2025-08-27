local M = {}

M.maxLineLength = tonumber(vim.g.LSP_MAX_LENGTH) or tonumber(vim.env.LSP_MAX_LENGTH) or 120
M.use_tabs = vim.g.INDENT_USE_TABS == true
M.default_indent_size = tonumber(vim.g.DEFAULT_INDENT_SIZE) or 4

M.indent_size = {
  lua = 2,
  json = 2,
  yaml = 2,
  yml = 2,
  xml = 2,
  css = 2,
  scss = 2,
  javascript = 2,
  javascriptreact = 2,
  typescript = 2,
  typescriptreact = 2,
  jsx = 2,
  tsx = 2,
  helm = 2,
  c = 4,
  cpp = 4,
  cs = 4,
  go = 4,
  html = 4,
  java = 4,
  php = 4,
  python = 4,
  rust = 4,
  sql = 4,
  sh = 4,
  bash = 4,
  zsh = 4,
  fish = 4,
}

return M
