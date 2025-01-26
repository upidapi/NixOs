vim.o.linebreak = true

-- use the spell file in the repo
-- if NIXOS_CONFIG_PATH is unset it falls back to the one
-- generated ad build time
local cfg = vim.env.NIXOS_CONFIG_PATH
if cfg then
    vim.o.spellfile = cfg
        .. "/modules/home/cli-apps/neovim/runtime/spell/en.utf-8.add"
end

vim.opt.spelloptions = { "camel", "noplainbuffer" }

vim.opt.spell = true
vim.opt.spelllang = { "en", "sv" }

-- from vim-dirtytalk
vim.opt.spelllang:append("prog")

-- disable spellchecking for asian characters (VIM algorithm does not support it)
-- vim.opt.spelllang:append('cjk')

-- as configured by `vim.spellcheck.ignoredFiletypes`
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "toggleterm" },
    callback = function()
        vim.opt_local.spell = false
    end,
})

vim.cmd([[hi clear SpellCap]])
vim.cmd([[hi clear SpellRare]])
vim.cmd([[hi SpellBad cterm=undercurl gui=undercurl guisp=#6E9E6E]])
