require("conform").setup({
    default_format_opts = {
        timeout_ms = 1000,
        async = true, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
    },
    formatters_by_ft = {
        -- Use the "*" filetype to run formatters on all filetypes.
        -- ["*"] = { "codespell" },
        -- Use the "_" filetype to run formatters on filetypes that don't
        -- have other formatters configured.
        ["_"] = { "trim_whitespace" },

        -- formatter for injected code
        injected = { options = { ignore_errors = true } },
    },
})
-- NOTE: you can show the status of the formatters with ConformInfo
