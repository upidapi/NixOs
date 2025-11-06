--- nushell ----
require("lspconfig").nushell.setup({})

-- https://github.com/nushell/nufmt/issues/11
-- Nufmt is WIP and currently in a broken state (pre alpha)
-- require("conform").formatters_by_ft.nu = { "nufmt" }
