vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = {"*.xaml"},
    command = "setfiletype xml",
})

vim.lsp.enable('lemminx')
