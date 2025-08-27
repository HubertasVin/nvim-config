local M = {}

local function goto_location(loc, enc, how)
  local fname = vim.uri_to_fname(loc.uri)
  if how == "vsplit" then
    vim.cmd.vsplit()
  elseif how == "split" then
    vim.cmd.split()
  elseif how == "tab" then
    vim.cmd.tabedit(fname)
  else
    vim.cmd.edit(fname)
  end

  local bufnr = vim.uri_to_bufnr(loc.uri)
  vim.fn.bufload(bufnr)
  local pos = (loc.range and loc.range.start) or { line = 0, character = 0 }
  local row = (pos.line or 0)
  local col = vim.lsp.util._get_line_byte_from_position(bufnr, pos, enc)
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

local function to_loc(item)
  if item.targetUri then
    return { uri = item.targetUri, range = item.targetSelectionRange or item.targetRange }
  end
  return item
end

local function build_items(items)
  local rows, locs = {}, {}
  for _, it in ipairs(items) do
    local loc = to_loc(it)
    local fname = vim.uri_to_fname(loc.uri)
    local start = loc.range.start
    local line = (start.line or 0) + 1
    local col = (start.character or 0) + 1
    local ok, file_lines = pcall(vim.fn.readfile, fname)
    local preview = ok and (file_lines[line] or "") or ""
    rows[#rows + 1] = string.format("%s:%d:%d  %s", vim.fn.fnamemodify(fname, ":."), line, col, preview)
    locs[#locs + 1] = loc
  end
  return rows, locs
end

local function open_picker(rows, locs, enc)
  local width = 0
  for _, l in ipairs(rows) do
    if #l > width then width = #l end
  end
  width = math.min(width + 2, math.max(50, math.floor(vim.o.columns * 0.7)))
  local height = math.min(#rows, math.floor(vim.o.lines * 0.5))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, rows)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false

  local function close_win()
    if win and vim.api.nvim_win_is_valid(win) then pcall(vim.api.nvim_win_close, win, true) end
  end
  local function idx() return vim.api.nvim_win_get_cursor(win)[1] end
  local function open_at(i, how)
    local loc = locs[i]; if not loc then return end
    close_win()
    goto_location(loc, enc, how)
  end

  vim.keymap.set("n", "<CR>", function() open_at(idx()) end, { buffer = buf, nowait = true })
  vim.keymap.set("n", "o", function() open_at(idx(), "split") end, { buffer = buf, nowait = true })
  vim.keymap.set("n", "v", function() open_at(idx(), "vsplit") end, { buffer = buf, nowait = true })
  vim.keymap.set("n", "t", function() open_at(idx(), "tab") end, { buffer = buf, nowait = true })
  vim.keymap.set("n", "q", close_win, { buffer = buf, nowait = true, silent = true })
  vim.keymap.set("n", "<Esc>", close_win, { buffer = buf, nowait = true, silent = true })
end

function M.definition_popup()
  local clients = vim.lsp.get_clients { bufnr = 0 }
  if #clients == 0 then return end
  local enc = clients[1].offset_encoding or "utf-16"
  local params = vim.lsp.util.make_position_params(0, enc)

  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result)
    if err or not result then return end
    local items = vim.islist(result) and result or { result }
    if #items == 0 then return end

    local rows, locs = build_items(items)
    if #rows == 1 then
      goto_location(locs[1], enc)
      return
    end
    open_picker(rows, locs, enc)
  end)
end

return M
