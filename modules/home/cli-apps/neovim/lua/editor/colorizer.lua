---- colorizer ----
-- https://github.com/norcalli/nvim-colorizer.lua
require("colorizer").setup({
    filetypes = { "*" },
    user_default_options = {
        RGB = true, -- #RGB hex codes #AFF
        RRGGBB = true, -- #RRGGBB hex codes #AAAAFF
        RRGGBBAA = true, -- #RRGGBBAA hex codes #AAFFAAAA
        AARRGGBB = false, -- 0xAARRGGBB hex codes0x0011
        rgb_fn = true, -- CSS rgb(255, 170, 170) and rgba() functions
        hsl_fn = true, -- CSS hsl(0, 100%, 83%) and hsla() functions

        names = false, -- "Name" codes like Blue or blue
        css = false, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
        css_fn = false, -- Enable all CSS *functions*: rgb_fn, hsl_fn

        -- Available modes for `mode`: foreground, background,  virtualtext
        mode = "background", -- Set the display mode.
        -- Available methods are false / true / "normal" / "lsp" / "both"
        -- True is same as normal
        tailwind = true, -- Enable tailwind colors
        virtualtext = "■",

        -- parsers can contain values used in |user_default_options|
        sass = {
            enable = false,
            parsers = { "css" },
        }, -- Enable sass colors

        -- update color values even if buffer is not focused
        -- example use: cmp_menu, cmp_docs
        always_update = false,
    },
    -- all the sub-options of filetypes apply to buftypes
    buftypes = {},
})

-- NOTE: ccc breaks nixd :)
