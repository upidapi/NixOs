-- https://github.com/akinsho/bufferline.nvim
require("bufferline").setup({
    options = {
        -- mode = 'tabs',
        numbers = 'none',
        close_command = 'bdelete! %d',
        right_mouse_command = '',
        left_mouse_command = 'buffer %d',
        middle_mouse_command = 'bdelete! %d',

        indicator = {
            -- icon = ' ', -- '▎',
            -- style = "icon",
            style = "none",
        },

        left_trunc_marker = '…',
        right_trunc_marker = '…',

        buffer_close_icon = '󰅖',
        modified_icon = '● ',
        close_icon = ' ',

        -- reserve space for neo-tree
        offsets = { {
            filetype = "neo-tree",
            -- text = vim.fn.getcwd,
            -- text_align = "right"
            text = "File Explorer",
            text_align = "center",
        } },

        color_icons = true,

        persist_buffer_sort = true,
        -- separator_style = "thin",
        -- enforce_regular_tabs = true,
        always_show_bufferline = true,
        sort_by = 'id',
    },
})
