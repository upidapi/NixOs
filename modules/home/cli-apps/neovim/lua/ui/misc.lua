require('tokyonight').setup {
    transparent = false,
}
vim.cmd [[colorscheme tokyonight-night]]


-- https://github.com/m4xshen/smartcolumn.nvim
require("smartcolumn").setup({
    colorcolumn = { "80", "100" },
    custom_colorcolumn = {},
    disabled_filetypes = {
        "help",
        "text",
        "markdown",
        "NvimTree",
        "alpha"
    }
})
