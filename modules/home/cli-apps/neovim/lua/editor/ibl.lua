------ indent blank line -------
-- https://github.com/lukas-reineke/indent-blankline.nvim
require("ibl").setup({
    debounce = 200,
    indent = {
        char = "│",
        priority = 1,
        repeat_linebreak = true,
        smart_indent_cap = true,
    },
    scope = {
        char = "│",
        enabled = true,
        exclude = {
            language = {},
            node_type = {
                ["*"] = {
                    "source_file",
                    "program",
                },
                lua = {
                    "chunk",
                },
                python = {
                    "module",
                },
            },
        },
        include = {
            node_type = {},
        },
        injected_languages = true,
        priority = 1024,
        show_end = false,
        show_exact_scope = false,
        show_start = false,
    },
    viewport_buffer = {
        max = 500,
        min = 30,
    },
    whitespace = {
        remove_blankline_trail = true,
    },
})
