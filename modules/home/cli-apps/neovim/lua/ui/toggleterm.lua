require("toggleterm").setup({
    direction = "horizontal",
    enable_winbar = false,

    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end,

    winbar = {
        enabled = true,
        name_formatter = function(term)
            return term.name
        end,
    },
})
