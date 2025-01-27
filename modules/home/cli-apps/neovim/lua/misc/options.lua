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

    updatetime = 50, -- for general actions
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
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

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

--[[
   x  l    use "999L, 888B" instead of "999 lines, 888 bytes"	shm-l

      m    use "[+]" instead of "[Modified]"			shm-m

      r    use "[RO]" instead of "[readonly]"			shm-r

      w    use "[w]" instead of "written" for file write message	shm-w
            and "[a]" instead of "appended" for ':w >> file' command

      a    all of the above abbreviations				shm-a

   x  o    overwrite message for writing a file with subsequent	shm-o
            message for reading a file (useful for ":wn" or when
           'autowrite' on)

   x  O    message for reading a file overwrites any previous	shm-O
            message;  also for quickfix message (e.g., ":cn")

      s    don't give "search hit BOTTOM, continuing at TOP" or	shm-s
            "search hit TOP, continuing at BOTTOM" messages; when using
            the search count do not show "W" before the count message
            (see shm-S below)

   x  t    truncate file message at the start if it is too long	shm-t
            to fit on the command-line, "<" will appear in the left most
            column; ignored in Ex mode

   x  T    truncate other messages in the middle if they are too	shm-T
            long to fit on the command line; "..." will appear in the
            middle; ignored in Ex mode

      W    don't give "written" or "[w]" when writing a file	shm-W

      A    don't give the "ATTENTION" message when an existing	shm-A
            swap file is found

      I    don't give the intro message when starting Vim,		shm-I
            see :intro

   x  c    don't give ins-completion-menu messages; for		shm-c
            example, "-- XXX completion (YYY)", "match 1 of 2", "The only
            match", "Pattern not found", "Back at original", etc.

   x  C    don't give messages while scanning for ins-completion	shm-C
            items, for instance "scanning tags"

      q    do not show "recording @a" when recording a macro	shm-q

   x  F    don't give the file info when editing a file, like	shm-F
            :silent was used for the command; note that this also
            affects messages from 'autoread' reloading

      S    do not show search count message when searching, e.g.	shm-S
            "[1/5]". When the "S" flag is not present (e.g. search count
            is shown), the "search hit BOTTOM, continuing at TOP" and
            "search hit TOP, continuing at BOTTOM" messages are only
            indicated by a "W" (Mnemonic: Wrapped) letter before the
            search count statistics.
]]
vim.opt.shortmess = "loOtTcCF"
-- vim.opt.shortmess = ""
