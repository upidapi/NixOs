require("lspconfig").phpactor.setup({})

require("lint").linters_by_ft.php = { "php" }

require("conform").formatters_by_ft.php = { "php_cs_fixer" }
