----- neo-tree -----
-- https://github.com/nvim-neo-tree/neo-tree.nvim
require("neo-tree").setup({
    add_blank_line_at_top = false,
    auto_clean_after_session_restore = false,
    default_source = "filesystem",
    enable_cursor_hijack = false,
    enable_diagnostics = true,
    enable_git_status = true,
    enable_modified_markers = true,
    enable_opened_markers = true,
    enable_refresh_on_write = true,
    git_status_async = false,
    hide_root_node = false,
    log_level = "info",
    log_to_file = false,
    open_files_do_not_replace_types = {
        "terminal",
        "Trouble",
        "qf",
        "edgy",
    },
    open_files_in_last_window = true,
    retain_hidden_root_indent = false,
    window = {
        width = 30,
    },
})
