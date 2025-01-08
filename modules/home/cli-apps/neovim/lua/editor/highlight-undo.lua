---- highlight undo -------
-- https://github.com/tzachar/highlight-undo.nvim
require('highlight-undo').setup({
    duration = 500,
    highlight_for_count = true,
    undo = {
        -- hlgroup = HighlightUndo, -- what is this defines as?
        mode = 'n',
        lhs = 'u',
        map = 'undo',
        opts = {}
    },


    redo = {
        -- hlgroup = HighlightUndo,
        mode = 'n',
        lhs = '<C-r>',
        map = 'redo',
        opts = {}
    },
})