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

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
	callback = function()
		lint.try_lint()
	end,
})
