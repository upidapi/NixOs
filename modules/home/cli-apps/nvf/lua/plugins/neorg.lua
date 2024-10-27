require('neorg').setup({
    load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {},
        -- ["core.completion"] = {
        --     ["config.engine"] = "nvim-cmp",
        -- },
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
    },
})
