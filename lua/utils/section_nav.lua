local M = {}

local function is_blank(ln)
  return vim.fn.getline(ln):match "^%s*$" ~= nil
end

-- Keep a line number within [1, $] and return both clamped line and last line
local function clamp(ln)
  local last = vim.fn.line "$"
  if ln < 1 then
    ln = 1
  elseif ln > last then
    ln = last
  end
  return ln, last
end

-- From a starting line, walk in `dir` (1 down, -1 up) until a nonblank is found.
local function scan_to_nonblank(ln, dir, last)
  local bound = dir > 0 and last or 1
  while ln ~= bound and is_blank(ln) do
    ln = ln + dir
  end
  if is_blank(ln) then
    return nil
  end
  return ln
end

-- Get the edge line number of the current text block in `dir`:
-- dir > 0 -> end of block; dir < 0 -> start of block.
local function block_edge(ln, dir)
  local cur, last = clamp(ln)

  -- If on blank, try to find the closest nonblank in the requested direction.
  local pos = is_blank(cur) and scan_to_nonblank(cur, dir, last) or cur
  if not pos then
    pos = scan_to_nonblank(cur, -dir, last)
  end
  -- Entire buffer is blank
  if not pos then
    return (dir > 0) and last or 1
  end

  -- Walk to the edge of the contiguous nonblank run
  local nxt = pos + dir
  while nxt >= 1 and nxt <= last and not is_blank(nxt) do
    pos, nxt = nxt, nxt + dir
  end
  return pos
end

-- Move the cursor to the given line and place it at end or start
local function place(ln, dir)
  vim.api.nvim_win_set_cursor(0, { ln, 0 })
  vim.cmd(dir > 0 and "normal! g_" or "normal! ^")
end

-- Perform one jump:
-- "next_end" -> to end of the current block or the next block;
-- "prev_start" -> to start of the current block or the previous block.
local function step(which)
  local dir = (which == "next_end") and 1 or -1
  local edge = block_edge(vim.fn.line ".", dir)

  -- If already at the edge, use built-in paragraph move to reach the next/prev block,
  -- then re-compute the edge there.
  if vim.fn.line "." == edge then
    vim.cmd("normal! " .. (dir > 0 and "}" or "{"))
    edge = block_edge(vim.fn.line ".", dir)
  end

  place(edge, dir)
end

function M.section_nav(which)
  local n = vim.v.count1
  for _ = 1, n do
    step(which)
  end
end

return M
