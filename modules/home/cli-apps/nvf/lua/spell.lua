vim.o.linebreak = true

-- added from the nix
-- vim.o.spellfile = "/nix/store/2ic8l7dfqi80bmwlrvzpq5y94si8h3ds-nvf-en.utf-8.add"

-- SECTION: spell-extra
vim.o.spelloptions = "camel";
vim.cmd[[hi clear SpellCap]];
vim.cmd[[hi clear SpellRare]];
vim.cmd[[hi SpellBad cterm=undercurl gui=undercurl guisp=#6E9E6E]];

-- SECTION: spellcheck
vim.opt.spell = true
vim.opt.spelllang = { "en", "sv" }

-- from vim-dirtytalk
vim.opt.spelllang:append("prog")

-- disable spellchecking for asian characters (VIM algorithm does not support it) 
vim.opt.spelllang:append('cjk')

-- as configured by `vim.spellcheck.ignoredFiletypes`
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "toggleterm" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- TODO: fix spelling, neovim cant find it
