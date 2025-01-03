-- required for the neorg cmp
require("blink.compat").setup({})
require("blink.cmp").setup({
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = { preset = 'default' },

    appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- Will be removed in a future release
        use_nvim_cmp_as_default = true,
        -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',

        kind_icons = require("lua.icons").kinds
    },

    completion = {
        list = {
            selection = "auto_insert",
        },

        menu = {
            border = "rounded",
            draw = {
                columns = { { 'kind' }, { 'label', 'label_description', gap = 1 } },
                treesitter = { "lsp" },
                -- winhighligh = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,EndOfBuffer:BlinkCmpDoc"
            }
        },

        documentation = {
            auto_show = true,
            auto_show_delay_ms = 0,

            window = {
                border = "rounded",
            }
        }
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
        default = { 'lsp', 'path', 'snippets', 'luasnip', 'buffer' },
    },

    -- doesn't work?
    providers = {
        lsp = { score_offset = 2, },
        path = { score_offset = 1, },
        snippets = { score_offset = 5, },
        luasnip = { score_offset = 5, },
        buffer = { score_offset = -1, },
    }
})
