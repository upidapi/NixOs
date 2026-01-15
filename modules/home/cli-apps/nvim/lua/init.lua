-- This is not the final init.lua but its good to control the order
-- of things.

-- enable experimental Lua module loader
vim.loader.enable()

local modules = {
    "lua.reload",
    "lua.tmp",
    "lua.mappings",
    "lua.icons",

    "lua.coding.auto-pairs",
    "lua.coding.comments",
    "lua.coding.guess-indent",
    "lua.coding.luasnip",
    "lua.coding.surround",

    "lua.ui.buffer-line",
    "lua.ui.cell-auto",

    "lua.ui.lualine",
    "lua.ui.misc",
    "lua.ui.smart-column",
    "lua.ui.neo-tree",
    -- I've come to the conclusion that i don't like it
    "lua.ui.noice",
    "lua.ui.telescope",
    "lua.ui.toggleterm",

    -- setting the theme in ui also sets spell color
    -- so it has to be after it
    "lua.coding.spell",

    -- the source of the ga_set_growsize errors
    "lua.editor.avante",
    "lua.editor.codesnap",
    "lua.editor.colorizer",

    "lua.editor.highlight-undo",
    "lua.editor.ibl",
    "lua.editor.image",
    "lua.editor.todo-comments", -- has to be after telescope
    "lua.editor.ufo",

    "lua.lsp.blink",
    "lua.lsp.dap",
    "lua.lsp.lint",
    "lua.lsp.lsp-saga",
    "lua.lsp.misc",
    "lua.lsp.treesitter",
    "lua.lsp.perfanno",
    "lua.lsp.conform",

    "lua.lang.bash",
    "lua.lang.cpp",
    "lua.lang.cs",
    "lua.lang.go",
    "lua.lang.java",
    "lua.lang.lua",
    "lua.lang.markdown",
    -- "lua.lang.neorg", -- BROKEN:
    "lua.lang.nix",
    "lua.lang.nu",
    "lua.lang.php",
    "lua.lang.python",
    "lua.lang.rust",
    -- "lua.lang.sql", -- disabled since it doesn't really work well
    "lua.lang.terraform",
    "lua.lang.typst",
    "lua.lang.web",
    "lua.lang.xml",

    -- has to be after lang/
    "lua.lsp.lspconfig", -- modifies the config

    "lua.misc.auto-save",
    "lua.misc.mouse",
    "lua.misc.options",
    "lua.misc.project-nvim",
    "lua.misc.shell"
}

-- Refresh module cache
for _, v in pairs(modules) do
    package.loaded[v] = nil
    require(v)
end
