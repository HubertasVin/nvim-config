local M = {}

local DIR_DOWN = 1
local DIR_UP = -1

local function is_blank_line(line)
  return vim.fn.getline(line):match "^%s*$" ~= nil
end

local function clamp_line(line)
  local last = vim.fn.line "$"
  if line < 1 then
    line = 1
  elseif line > last then
    line = last
  end
  return line, last
end

local function seek_nonblank(line, direction, last)
  local bound = direction > 0 and last or 1
  while line ~= bound and is_blank_line(line) do
    line = line + direction
  end
  if is_blank_line(line) then
    return nil
  end
  return line
end

local function text_block_edge(line, direction)
  local cur, last = clamp_line(line)
  local pos = is_blank_line(cur) and seek_nonblank(cur, direction, last) or cur
  if not pos then
    pos = seek_nonblank(cur, -direction, last)
  end
  if not pos then
    return direction > 0 and last or 1
  end
  local nxt = pos + direction
  while nxt >= 1 and nxt <= last and not is_blank_line(nxt) do
    pos, nxt = nxt, nxt + direction
  end
  return pos
end

local function ts_query(lang, name)
  local ok, q = pcall(vim.treesitter.query.get, lang, name)
  if ok and q then
    return q
  end
  local ok_compat, q_compat = pcall(vim.treesitter.query.get_query, lang, name)
  if ok_compat and q_compat then
    return q_compat
  end
  return nil
end

local function ts_lang(bufnr)
  local ft = vim.bo[bufnr].filetype
  local ok, lang = pcall(function()
    return (vim.treesitter.language and vim.treesitter.language.get_lang(ft)) or ft
  end)
  return ok and lang or ft
end

local function push_block(blocks, seen, node)
  local srow, _, erow, _ = node:range()
  if srow and erow and erow > srow then
    local key = srow .. ":" .. erow
    if not seen[key] then
      seen[key] = true
      blocks[#blocks + 1] = { start_line = srow + 1, end_line = erow + 1, node = node }
    end
  end
end

local function collect_semantic_blocks()
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = vim.treesitter.get_parser(bufnr)
  if not parser then
    return {}
  end

  local tree = parser:parse()[1]
  if not tree then
    return {}
  end

  local root = tree:root()
  local blocks, seen = {}, {}
  local lang = ts_lang(bufnr)

  local folds_q = ts_query(lang, "folds")
  if folds_q then
    local srow, _, erow, _ = root:range()
    for id, node in folds_q:iter_captures(root, bufnr, srow, erow + 1) do
      if folds_q.captures[id] == "fold" then
        push_block(blocks, seen, node)
      end
    end
  else
    local locals_q = ts_query(lang, "locals")
    if locals_q then
      local srow, _, erow, _ = root:range()
      for id, node in locals_q:iter_captures(root, bufnr, srow, erow + 1) do
        if locals_q.captures[id] == "scope" then
          push_block(blocks, seen, node)
        end
      end
    else
      local function walk(n)
        if n:named() then
          local t = n:type()
          if not t:find "comment" and not t:find "string" then
            push_block(blocks, seen, n)
          end
        end
        for child in n:iter_children() do
          walk(child)
        end
      end
      walk(root)
    end
  end

  table.sort(blocks, function(a, b)
    if a.start_line == b.start_line then
      return a.end_line < b.end_line
    end
    return a.start_line < b.start_line
  end)

  return blocks
end

local function boundaries_for(direction)
  local blocks = collect_semantic_blocks()
  if #blocks == 0 then
    return {}
  end
  local list = {}
  for i = 1, #blocks do
    list[i] = direction > 0 and blocks[i].end_line or blocks[i].start_line
  end
  table.sort(list)
  return list
end

local function next_semantic_boundary(current_line, direction)
  local list = boundaries_for(direction)
  if #list == 0 then
    return nil
  end
  if direction > 0 then
    for i = 1, #list do
      if list[i] > current_line then
        return list[i]
      end
    end
  else
    for i = #list, 1, -1 do
      if list[i] < current_line then
        return list[i]
      end
    end
  end
  return nil
end

local function move_cursor(line, direction)
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.cmd(direction > 0 and "normal! g_" or "normal! ^")
end

local function step(which)
  local direction = which == "next_end" and DIR_DOWN or DIR_UP
  local current = vim.fn.line "."
  local target = next_semantic_boundary(current, direction)
  if not target then
    local edge = text_block_edge(current, direction)
    if current == edge then
      vim.cmd("normal! " .. (direction > 0 and "}" or "{"))
      edge = text_block_edge(vim.fn.line ".", direction)
    end
    target = edge
  end
  move_cursor(target, direction)
end

function M.section_nav(which)
  local n = vim.v.count1
  for _ = 1, n do
    step(which)
  end
end

return M
