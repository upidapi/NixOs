local options = {
    showmode = true,

    showtabline = 2, -- always show tab line

    encoding = "utf-8",
    hidden = true,

    vim.opt.shortmess:append("c"),
    vim.opt.clipboard:append("unnamedplus"),

    termguicolors = true,

    wrap = true,
    linebreak = true,

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

    cmdheight = 1,

    updatetime = 50, -- for general actions
    timeoutlen = 500, -- for keybinds

    cursorlineopt = "line",
    cursorcolumn = false,
    scrolloff = 0,

    splitbelow = true,
    splitright = true,

    signcolumn = "yes",
    number = true,
    numberwidth = 1,
    relativenumber = true,
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- TODO: format on save?

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
]==]--

vim.g.mapleader = " "
-- vim.g.maplocalleader = " "
-- map <C-Space> to <Leader> in insert
vim.api.nvim_set_keymap(
    'i', '<C-Space>', '<C-o><leader>',
    { noremap = true, silent = true }
)


require("auto-save").setup {
  debounce_delay = 1000,

  condition = function(buf)
    local fn = vim.fn
    local utils = require("auto-save.utils.data")

    -- only save text files
    if utils.not_in(fn.getbufvar(buf, "&filetype"), {'txt', 'md'}) then
      return false
    end

    return true
  end
}


