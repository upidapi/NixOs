-- https://github.com/mistricky/codesnap.nvim
require("codesnap").setup({
    -- The save_path must be ends with .png, unless when you specified a directory path,
    -- CodeSnap will append an auto-generated filename to the specified directory path
    -- For example:
    -- save_path = "~/Pictures"
    -- parsed: "~/Pictures/CodeSnap_y-m-d_at_h:m:s.png"
    -- save_path = "~/Pictures/foo.png"
    -- parsed: "~/Pictures/foo.png"
    save_path = "~/images/CodeSnap_y-m-d_at_h:m:s.png",

    mac_window_bar = false,
    -- title = "CodeSnap.nvim",
    code_font_family = "CaskaydiaCove Nerd Font",
    watermark_font_family = "Pacifico",
    watermark = "",
    bg_theme = "none",
    breadcrumbs_separator = "/",
    has_breadcrumbs = true,
    has_line_number = true,
    show_workspace = true,
    min_width = 0,
    bg_x_padding = 0,
    bg_y_padding = 0,
})
