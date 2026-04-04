local lint = require "lint"

lint.linters_by_ft = {
	ansible = { "ansible_lint" },
	dockerfile = { "hadolint" },
	go = { "golangcilint" },
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	json = { "jsonlint" },
	python = { "ruff" },
	sh = { "shellcheck" },
	bash = { "shellcheck" },
	zsh = { "shellcheck" },
	terraform = { "tflint" },
	tf = { "tflint" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	vue = { "eslint_d" },
	yaml = { "yamllint" },
}

local function debounce(ms, fn)
	local timer = vim.uv.new_timer()
	return function(...)
		local args = { ... }
		timer:stop()
		timer:start(ms, 0, function()
			timer:stop()
			vim.schedule(function()
				fn(unpack(args))
			end)
		end)
	end
end

local do_lint = debounce(150, function()
	lint.try_lint()
end)

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
	callback = do_lint,
})
