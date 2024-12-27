-- This is not the final init.lua but its good to control the order
-- of things.

-- enable experimental Lua module loader
vim.loader.enable()

local modules = {
    -- "lua.misc",
    --
    -- "lua.lsp",
    -- "lua.mappings",
    -- "lua.mouse",
    -- "lua.reload",
    -- "lua.text",
    --
    -- "lua.ui",
    -- "lua.plugins.lualine",
    --
    -- -- setting the theme in ui also sets spell color
    -- "lua.spell",
    --
    -- "lua.plugins.telescope",
    -- "lua.plugins.todo-comments", -- has to be after telescope
    --
    -- "lua.plugins.cell-auto",
    -- "lua.plugins.dap",
    -- "lua.plugins.image",
    -- "lua.plugins.luasnip",
    -- "lua.plugins.neorg",
    -- "lua.plugins.toggleterm",

    "lua.reload",
    "lua.mappings",
    "lua.icons",

    "lua.coding.auto-pairs",
    "lua.coding.comments",
    "lua.coding.guess-indent",
    "lua.coding.luasnip",

    "lua.ui.buffer-line",
    "lua.ui.cell-auto",
    "lua.ui.lualine",
    "lua.ui.misc",
    "lua.ui.neo-tree",
    "lua.ui.noice",
    "lua.ui.telescope",
    "lua.ui.toggleterm",

    -- setting the theme in ui also sets spell color
    -- so it has to be after it
    "lua.coding.spell",

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
    "lua.lsp.conform",

    "lua.lang.bash",
    "lua.lang.cpp",
    "lua.lang.lua",
    "lua.lang.markdown",
    "lua.lang.neorg",
    "lua.lang.nix",
    "lua.lang.nu",
    "lua.lang.python",
    "lua.lang.rust",
    "lua.lang.web",

    -- has to be after lang/
    "lua.lsp.lspconfig", -- modifies the config

    "lua.misc.auto-save",
    "lua.misc.mouse",
    "lua.misc.options",
    "lua.misc.project-nvim",
}


-- Refresh module cache
for _, v in pairs(modules) do
    package.loaded[v] = nil
    require(v)
end
