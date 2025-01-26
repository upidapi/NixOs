-- https://github.com/ahmedkhalf/project.nvim
-- auto cd into project root
require("project_nvim").setup({
    detection_methods = {
        "lsp",
        "pattern",
    },
    exclude_dirs = {},
    lsp_ignored = {},
    manual_mode = true,
    patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        "flake.nix",
        "cargo.toml",
    },
    scope_chdir = "global",
    show_hidden = false,
    silent_chdir = true,
})
