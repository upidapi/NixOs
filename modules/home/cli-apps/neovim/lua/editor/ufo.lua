----- nvim ufo ------
local ufo = require('ufo')
ufo.setup()

vim.o.foldcolumn = '0' -- '1' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- fold are built in, see binds here
-- use uppercase for the char to do it recursively
-- za - toggle
-- zc - close
-- zo - open
-- etc
-- https://neovim.io/doc/user/fold.html#fold-commands
vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds)
vim.keymap.set('n', 'zm', ufo.closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
