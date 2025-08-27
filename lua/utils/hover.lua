local M = {}

local NS = vim.api.nvim_create_namespace "HoverDiag"

local function sev_meta(sev)
  local s = vim.diagnostic.severity
  if sev == s.ERROR then
    return "Error", "DiagnosticError"
  end
  if sev == s.WARN then
    return "Warn", "DiagnosticWarn"
  end
  if sev == s.INFO then
    return "Info", "DiagnosticInfo"
  end
  return "Hint", "DiagnosticHint"
end

local function trim_edges(lines)
  if type(lines) ~= "table" then
    return {}
  end
  local function blank(str)
    return not str or str:match "^%s*$" ~= nil
  end
  local first, last = 1, #lines
  while first <= last and blank(lines[first]) do
    first = first + 1
  end
  while last >= first and blank(lines[last]) do
    last = last - 1
  end
  local out = {}
  for i = first, last do
    out[#out + 1] = lines[i]
  end
  return out
end

local function build_diag_section(bufnr)
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diags = vim.diagnostic.get(bufnr, { lnum = row })
  if not diags or #diags == 0 then
    return nil, nil
  end

  local lines, hl = {}, {}
  lines[#lines + 1] = "Diagnostics"
  lines[#lines + 1] = "───────────"

  for _, d in ipairs(diags) do
    local tag, group = sev_meta(d.severity)
    local src = d.source and (" (" .. d.source .. ")") or ""
    local parts = vim.split(d.message or "", "\n", { trimempty = true })

    local first = string.format("%s: %s%s", tag, parts[1] or "", src)
    lines[#lines + 1] = first
    hl[#hl + 1] = {
      line = #lines - 1,
      col_start = 0,
      col_end = #tag + 1,
      hl = group,
      priority = 200,
    }

    for i = 2, #parts do
      lines[#lines + 1] = "  " .. parts[i]
    end
  end

  lines[#lines + 1] = ""
  return lines, hl
end

local function build_desc_section(result)
  if not result or not result.contents then
    return nil
  end
  local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  lines = trim_edges(lines or {})
  if #lines == 0 then
    return nil
  end

  local out = {}
  out[#out + 1] = "Description"
  out[#out + 1] = "───────────"
  for _, l in ipairs(lines) do
    out[#out + 1] = l
  end
  return out
end

local function apply_highlights(bufnr, highlights)
  if not highlights then
    return
  end
  for _, h in ipairs(highlights) do
    vim.api.nvim_buf_set_extmark(bufnr, NS, h.line, h.col_start or 0, {
      hl_group = h.hl,
      end_row = h.line,
      end_col = (h.col_end or 0),
      hl_eol = false,
    })
  end
end

local function render_popup(all_lines, highlights)
  local opts = {
    border = "rounded",
    focusable = true,
    close_events = {},
  }

  local bufnr, winid = vim.lsp.util.open_floating_preview(all_lines, "markdown", opts)

  apply_highlights(bufnr, highlights)

  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].bufhidden = "wipe"
  vim.wo[winid].wrap = true
  vim.wo[winid].linebreak = true
  vim.wo[winid].breakindent = true

  local prev_win = vim.api.nvim_get_current_win()
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_set_current_win(winid)
  end

  local function close_win()
    if winid and vim.api.nvim_win_is_valid(winid) then
      pcall(vim.api.nvim_win_close, winid, true)
    end
    if prev_win and vim.api.nvim_win_is_valid(prev_win) then
      pcall(vim.api.nvim_set_current_win, prev_win)
    end
  end

  vim.keymap.set("n", "q", close_win, { buffer = bufnr, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close_win, { buffer = bufnr, nowait = true, silent = true })

  return bufnr, winid
end

local function show_combined(diag_lines, diag_hl, hover_lines)
  local lines, hl = {}, {}

  if diag_lines and #diag_lines > 0 then
    for _, l in ipairs(diag_lines) do
      lines[#lines + 1] = l
    end
    for _, h in ipairs(diag_hl or {}) do
      hl[#hl + 1] = h
    end
  end

  if hover_lines and #hover_lines > 0 then
    if #lines > 0 and lines[#lines] ~= "" then
      lines[#lines + 1] = ""
    end
    for _, l in ipairs(hover_lines) do
      lines[#lines + 1] = l
    end
  end

  if #lines == 0 then
    lines = { "No hover or diagnostics." }
  end
  render_popup(lines, hl)
end

function M.hover_with_diagnostics()
  local bufnr = 0
  local diag_lines, diag_hl = build_diag_section(bufnr)

  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if #clients == 0 then
    show_combined(diag_lines, diag_hl, nil)
    return
  end

  local enc = clients[1].offset_encoding or "utf-16"
  local params = vim.lsp.util.make_position_params(0, enc)

  vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result)
    if err then
      show_combined(diag_lines, diag_hl, nil)
      return
    end
    local hover_lines = build_desc_section(result)
    show_combined(diag_lines, diag_hl, hover_lines)
  end)
end

return M
