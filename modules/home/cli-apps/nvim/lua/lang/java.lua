vim.lsp.enable("java_language_server")

require("lint").linters_by_ft.java = { "checkstyle" }

require("conform").formatters_by_ft.java = { "google-java-format" }
