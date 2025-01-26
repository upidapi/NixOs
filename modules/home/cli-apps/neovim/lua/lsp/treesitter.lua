----------------------
-- About treesitter --
----------------------
require("nvim-treesitter.configs").setup({
    -- Disable imperative treesitter options that would attempt to fetch
    -- grammars into the read-only Nix store. To add additional grammars here
    -- you must use the `config.vim.treesitter.grammars` option.
    auto_install = false,
    sync_install = false,
    ensure_installed = {},

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
