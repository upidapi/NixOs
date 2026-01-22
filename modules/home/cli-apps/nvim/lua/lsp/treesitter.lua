----------------------
-- About treesitter --
----------------------
-- TODO: migrate to treesitter main
-- they did a rewrite that broke everything
-- stay on old until i get the energy to resolve it
-- require("nvim-treesitter").setup({
--     -- Disable imperative treesitter options that would attempt to fetch
--     -- grammars into the read-only Nix store. To add additional grammars here
--     -- you must use the `config.vim.treesitter.grammars` option.
--     auto_install = false,
--     sync_install = false,
--     ensure_installed = {},
--
--     highlight = {
--         enable = true,
--         additional_vim_regex_highlighting = false,
--     },
--
--     indent = {
--         enable = true,
--     },
--
--     incremental_selection = {
--         enable = true,
--         keymaps = {
--             init_selection = "gsi",
--             node_incremental = "gsi",
--             scope_incremental = "gsc",
--             node_decremental = "gsm",
--         },
--     },
-- })
--
-- vim.api.nvim_create_autocmd('FileType', {
--     callback = function()
--         pcall(vim.treesitter.start)
--     end,
-- })
--
-- -- TODO:
-- -- vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- -- vim.wo[0][0].foldmethod = 'expr'
-- --
-- -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
-- --
-- --
require("nvim-treesitter.configs").setup({
    -- Disable imperative treesitter options that would attempt to fetch
    -- grammars into the read-only Nix store. To add additional grammars here
    -- you must use the `config.vim.treesitter.grammars` option.
    auto_install = false,
    sync_install = false,
    ensure_installed = {},

    -- autotag = {
    --     enable = true,
    --     filetypes = {
    --         "html",
    --         "javascript",
    --         "typescript",
    --         "javascriptreact",
    --         "typescriptreact",
    --         "svelte",
    --         "vue",
    --         "tsx",
    --         "jsx",
    --         "rescript",
    --         "css",
    --         "lua",
    --         "xml",
    --         "php",
    --         "markdown",
    --     },
    -- },

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },

    indent = {
        enable = true,
    },

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = "gsi",
            node_incremental = "gsi",
            scope_incremental = "gsc",
            node_decremental = "gsm",
        },
    },
})
