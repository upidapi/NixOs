----- image nvim ------
-- https://github.com/3rd/image.nvim
-- default config + ueberzug
--
require("image").setup({
    -- backend = "ueberzug",
    backend = "kitty",
    integrations = {
        markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            -- markdown extensions (ie. quarto) can go here
            filetypes = { "markdown", "vimwiki" },
        },
        neorg = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "norg" },
        },
        html = {
            enabled = false,
        },
        css = {
            enabled = false,
        },
    },
    max_width = nil,
    max_height = nil,
    max_width_window_percentage = nil,
    max_height_window_percentage = 50,
    -- toggles images when windows are overlapped
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "notify", "" },
    -- auto show/hide images when the editor gains/looses focus
    editor_only_render_when_focused = false,
    -- auto show/hide images in the correct Tmux window (needs visual-activity off)
    tmux_show_only_in_active_window = false,
    hijack_file_patterns = {
        "*.png",
        "*.jpg",
        "*.jpeg",
        "*.gif",
        "*.webp",
    }, -- render image files as images when opened
})

-- https://github.com/HakonHarnes/img-clip.nvim
require("img-clip").setup({
    default = {
        drag_and_drop = {
            enabled = true,
            insert_mode = true,
            download_images = true,
        },
        prompt_for_file_name = true,
        use_cursor_in_template = true,
        insert_mode_after_paste = true,
        embed_image_as_base64 = false,
    },

    tex = {
        template = [[
    \begin{figure}[h]
      \centering
      \includegraphics[width=0.8\textwidth]{$FILE_PATH}
      \caption{$CURSOR}
      \label{fig:$LABEL}
    \end{figure}
        ]],
        use_absolute_path = false,
        relative_to_current_file = true,
    },
})
