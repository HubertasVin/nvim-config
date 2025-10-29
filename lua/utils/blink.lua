local M = {}

function M.close()
	local ok, blink = pcall(require, "blink.cmp")
	if ok and blink and (blink.is_visible and blink.is_visible()) then
		if blink.cancel then
			blink.cancel()
		end
		if blink.hide then
			blink.hide()
		end
		return ""
	end
	return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
end

return M
