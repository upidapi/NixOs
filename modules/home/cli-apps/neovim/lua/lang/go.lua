require("lspconfig").gopls.setup({})

require("lint").linters_by_ft.go = { "golangcilint" }

require("conform").formatters_by_ft.go = { "gofumpt" }
