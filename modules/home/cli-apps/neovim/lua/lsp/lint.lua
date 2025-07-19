require("lint").linters_by_ft = {
    -- set in lang/
    -- javascript = { 'eslint' },
    -- typescript = { 'eslint' },
    -- javascriptreact = { 'eslint' },
    -- typescriptreact = { 'eslint' },
}
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function()
        require("lint").try_lint()
    end,
})
