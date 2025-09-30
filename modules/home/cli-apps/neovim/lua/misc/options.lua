local options = {
    showmode = true,

    showtabline = 2, -- always show tab line

    encoding = "utf-8",
    hidden = true,

    -- system clipboard
    clipboard = "unnamedplus",

    termguicolors = true,

    wrap = true,
    linebreak = true,
    -- smoothscroll = true, -- doesn't seam to work

    -- for search
    smartcase = false,
    ignorecase = false,

    swapfile = false,
    backup = false,
    writebackup = false,
    undofile = true,

    -- a great prank to turn on for an enemy
    errorbells = false,
    visualbell = false,

    -- default tab size
    tabstop = 4,
    shiftwidth = 4,
    softtabstop = 4,

    expandtab = true,
    autoindent = true,
    smartindent = true,

    updatetime = 50,  -- for general actions
    timeoutlen = 500, -- for keybinds

    cursorlineopt = "line",
    cursorcolumn = false,
    scrolloff = 8,

    splitbelow = true,
    splitright = true,

    signcolumn = "yes",
    number = true,
    numberwidth = 1,
    relativenumber = true,

    -- no fucking newlines on eof
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- TODO: figure out how to prevent eof vim
-- doesnt work
-- vim.cmd("set nofixeol")
-- vim.cmd("set nofixendofline")

vim.cmd("set nosmartindent")

-- use gq[G] to format
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "text", "markdown" },
    callback = function()
        vim.opt_local.textwidth = 80

        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.softtabstop = 2
    end,
})

--[==[
-- for markdow preview
vim.g.mkdp_auto_close = true
vim.g.mkdp_auto_start = false
vim.g.mkdp_command_for_global = false
vim.g.mkdp_filetypes = {"'markdown'"}
vim.g.mkdp_open_ip = {["_type"] = "if",["condition"] = false,["content"] = ""}
vim.g.mkdp_open_to_the_world = false
vim.g.mkdp_port = {["_type"] = "if",["condition"] = false,["content"] = ""}
vim.g.mkdp_refresh_slow = false
]==]
--

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.editorconfig =
    true,
    -- map <C-Space> to <Leader> in insert
    vim.api.nvim_set_keymap(
        "i",
        "<C-Space>",
        "<C-o><leader>",
        { noremap = true, silent = true }
    )

vim.opt.shortmess = "loOtTcCF"
