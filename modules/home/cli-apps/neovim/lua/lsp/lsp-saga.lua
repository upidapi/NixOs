-------------------
-- About lspsaga --
-------------------
local colors, kind
colors = { normal_bg = "#3b4252" }
require("lspsaga").setup({
    ui = {
        colors = colors,
        kind = kind,
        border = "single",
    },
    outline = {
        win_width = 25,
    },
    lightbulb = {
        enable = false,
    },
    symbol_in_winbar = {
        enable = false,
    },
})
