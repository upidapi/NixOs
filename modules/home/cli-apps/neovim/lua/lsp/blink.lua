-- required for the neorg cmp
require("blink.compat").setup({})
require("blink.cmp").setup({
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = {
        preset = "default",

        ["<C-j>"] = { "snippet_forward", "fallback" },
        ["<C-k>"] = { "snippet_backward", "fallback" },
    },

    appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "mono",

        kind_icons = require("lua.icons").kinds,
    },

    completion = {
        list = {
            selection = {
                -- auto select first item
                preselect = true,

                -- When `true`, inserts the completion item automatically when
                -- selecting it
                -- You may want to bind a key to the `cancel` command
                -- (default <C-e>) when using this option,
                -- which will both undo the selection and hide the completion menu
                auto_insert = true,
            },
        },

        menu = {
            border = "rounded",
            draw = {
                columns = {
                    { "kind" },
                    { "label", "label_description", gap = 1 },
                },
                treesitter = { "lsp" },
                -- winhighligh = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc"
            },
        },

        documentation = {
            auto_show = true,
            auto_show_delay_ms = 100,

            window = {
                border = "rounded",
            },
        },
    },

    snippets = { preset = "luasnip" },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        -- doesn't work?
        providers = {
            lsp = { score_offset = 2 },
            path = { score_offset = 1 },
            snippets = { score_offset = 3 },
            buffer = { score_offset = 0 },
        },
    },
})
