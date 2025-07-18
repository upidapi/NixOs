-- https://github.com/akinsho/bufferline.nvim

require("bufferline").setup({
    options = {
        -- mode = 'tabs',
        numbers = "none",
        -- use Bdelete (from vim-bbye) to prevent it from messing
        -- with the layout
        close_command = "Bdelete! %d",
        middle_mouse_command = "Bdelete! %d",
        right_mouse_command = "",
        left_mouse_command = "buffer %d",

        indicator = {
            -- icon = ' ', -- '▎',
            -- style = "icon",
            style = "none",
        },

        ---@type fun(buf: {
        ---    name: string,
        ---    path: string,
        ---    bufnr: number,
        ---    tabnr: number,
        ---    buffers: table}): string
        name_formatter = function(buf)
            local buf_type = vim.fn.getbufvar(buf.bufnr, "&buftype")

            if buf_type == "" then
                if buf.name ~= "" then
                    return buf.name
                else
                    return "[No Name]"
                end
            elseif buf_type == "quickfix" then
                return "[Quickfix List]"
            elseif buf_type == "help" then
                return "[Help]"
            end

            -- shouldn't happen
            return "[" .. buf_type .. "]"
        end,

        left_trunc_marker = "…",
        right_trunc_marker = "…",

        buffer_close_icon = "󰅖",
        modified_icon = "● ",
        close_icon = " ",

        -- reserve space for neo-tree
        offsets = {
            {
                filetype = "neo-tree",
                -- text = vim.fn.getcwd,
                -- text_align = "right"
                text = "File Explorer",
                text_align = "center",
            },
        },

        color_icons = true,

        persist_buffer_sort = true,
        -- separator_style = "thin",
        -- enforce_regular_tabs = true,
        always_show_bufferline = true,
        sort_by = "id",
    },
})
