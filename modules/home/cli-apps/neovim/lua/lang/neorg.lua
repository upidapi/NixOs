require("neorg").setup({
    load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        ["core.completion"] = {
            config = {
                -- engine = {
                --     module_name = "external.lsp-completion"
                -- },
                engine = "nvim-cmp",
            },
        },
        -- ["core.integrations.image"] = {},
        ["core.export"] = {},
        ["core.summary"] = {},
        ["core.text-objects"] = {},
        ["core.dirman"] = {
            config = {
                workspaces = {
                    notes = "~/neorg",
                },
            },
        },
        -- ["external.interim-ls"] = {
        --     config = {
        --         -- default config shown
        --         completion_provider = {
        --             -- Enable or disable the completion provider
        --             enable = true,
        --
        --             -- Show file contents as documentation when you complete a file name
        --             documentation = true,
        --
        --             -- Try to complete categories provided by Neorg Query. Requires `benlubas/neorg-query`
        --             categories = false,
        --         }
        --     }
        -- },
    },
})
