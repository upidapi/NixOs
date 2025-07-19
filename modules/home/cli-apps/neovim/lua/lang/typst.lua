-- has everything from formatting to previews
require("lspconfig").tinymist.setup({
    settings = {
        formatterMode = "typstyle",
        exportPdf = "onType",
        semanticTokens = "disable",
    },
})

require("typst-preview").setup({})

-- https://github.com/OXY2DEV/markview.nvim?
