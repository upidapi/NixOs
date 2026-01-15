-- has everything from formatting to previews
vim.lsp.config("tinymist", {
    settings = {
        formatterMode = "typstyle",
        exportPdf = "onType",
        semanticTokens = "disable",
    },
})
vim.lsp.enable("tinymist")

require("typst-preview").setup({})

-- https://github.com/OXY2DEV/markview.nvim?
