local nvim_tree_select = require("nvim-treesitter.incremental_selection")
local dap = require("dap")

local mappings = {
    -- open toggle term
    -- { "n", "<c-t>",       "<Cmd>execute v:count . \"ToggleTerm\"<CR>" },

    { "n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>" },

    -- bind the key that is where : "usually" is to :
    { "n", "Ö", ":" },

    -- move one visual line with arrow keys
    { "i", "<up>", "<c-o>g<up>" },
    { "i", "<down>", "<c-o>g<down>" },
    { "n", "<up>", "g<up>" },
    { "n", "<down>", "g<down>" },
    { "v", "<up>", "g<up>" },
    { "v", "<down>", "g<down>" },

    -- exit terminal mode with esc
    { "t", "<Esc>", "<C-><C-n>" },

    -- format
    {
        "n",
        "<F3>",
        function()
            -- vim.lsp.buf.format({ async = true })
            require("conform").format()
        end,
    },

    { "n", "<leader>d.", dap.run_last },
    { "n", "<leader>dc", dap.continue },
    { "n", "<leader>dC", dap.run_to_cursor },
    { "n", "<leader>dR", dap.restart },
    { "n", "<leader>db", dap.toggle_breakpoint },
    { "n", "<leader>dc", dap.continue },
    { "n", "<leader>di", dap.step_into },
    { "n", "<leader>dj", dap.step_over },
    { "n", "<leader>dk", dap.step_back },
    { "n", "<leader>do", dap.step_out },
    { "n", "<leader>dq", dap.terminate },
    { "n", "<leader>dr", dap.repl.toggle },
    { "n", "<leader>dvi", dap.down },
    { "n", "<leader>dvo", dap.up },
    { "n", "<leader>dh", require("dap.ui.widgets").hover },
    { "n", "<leader>du", require("dapui").toggle },

    -- seams to do the same as node_incremental
    -- { "n", "gnn",         nvim_tree_select.init_selection },
    { "x", "gsJ", nvim_tree_select.scope_incremental },
    { "n", "gsj", nvim_tree_select.node_decremental },
    { "n", "gsk", nvim_tree_select.node_incremental },

    { "n", "<leader>fC", "<cmd> Telescope git_commits<CR>" },
    { "n", "<leader>fb", "<cmd> Telescope buffers<CR>" },
    { "n", "<leader>fc", "<cmd> Telescope git_bcommits<CR>" },
    { "n", "<leader>ff", "<cmd> Telescope find_files<CR>" },
    { "n", "<leader>fg", "<cmd> Telescope live_grep<CR>" },
    { "n", "<leader>fp", "<cmd> Telescope projects<CR>" },
    { "n", "<leader>fr", "<cmd> Telescope resume<CR>" },
    { "n", "<leader>fz", "<cmd> Telescope current_buffer_fuzzy_find<CR>" },
    -- find todos in telescope, but exclude some types
    { "n", "<leader>ft", "<cmd> TodoTelescopeCat<CR>" },

    { "n", "<leader>tr", "<cmd> Neotree reveal<CR>" },
    { "n", "<leader>tt", "<cmd> Neotree toggle<CR>" },
    { "n", "<leader>tu", "<cmd> Neotree<CR>" },

    -- Lsp
    { "n", "gh", "<cmd>Lspsaga lsp_finder<CR>" },
    { "n", "<leader>ca", "<cmd>Lspsaga code_action<CR>" },
    { "n", "gr", "<cmd>Lspsaga rename<CR>" },
    { "n", "gr", "<cmd>Lspsaga rename ++project<CR>" },
    { "n", "gD", "<cmd>Lspsaga peek_definition<CR>" },
    { "n", "gd", "<cmd>Lspsaga goto_definition<CR>" },
    { "n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>" },
    { "n", "<leader>sc", "<cmd>Lspsaga show_cursor_diagnostics<CR>" },
    { "n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>" },
    { "n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>" },
    { "n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>" },
    {
        "n",
        "[E",
        function()
            require("lspsaga.diagnostic"):goto_prev({
                severity = vim.diagnostic.severity.ERROR,
            })
        end,
    },
    {
        "n",
        "]E",
        function()
            require("lspsaga.diagnostic"):goto_next({
                severity = vim.diagnostic.severity.ERROR,
            })
        end,
    },
    { "n", "ss", "<cmd>Lspsaga outline<CR>" },
    { "n", "K", "<cmd>Lspsaga hover_doc ++keep<CR>" },
    { "n", "<Leader>ci", "<cmd>Lspsaga incoming_calls<CR>" },
    { "n", "<Leader>co", "<cmd>Lspsaga outgoing_calls<CR>" },
    -- { "n", "<A-d>",       "<cmd>Lspsaga term_toggle<CR>" },
    -- { "t", "<A-d>",       "<cmd>Lspsaga term_toggle<CR>" },

    -- { 'n', '<leader>lgD', vim.lsp.buf.declaration },
    -- { 'n', '<leader>lgd', vim.lsp.buf.definition },
    -- { 'n', '<leader>lgt', vim.lsp.buf.type_definition },
    -- { 'n', '<leader>lgi', vim.lsp.buf.implementation },
    -- { 'n', '<leader>lgr', vim.lsp.buf.references },
    -- { 'n', '<leader>lgn', vim.diagnostic.goto_next },
    -- { 'n', '<leader>lgp', vim.diagnostic.goto_prev },
    -- { 'n', '<leader>le',  vim.diagnostic.open_float },
    -- { 'n', '<leader>lH',  vim.lsp.buf.document_highlight },
    -- { 'n', '<leader>lS',  vim.lsp.buf.document_symbol },
    -- { 'n', '<leader>lwa', vim.lsp.buf.add_workspace_folder },
    -- { 'n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder },
    -- { 'n', '<leader>lwl', function()
    --     print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end },
    -- { 'n', '<leader>lws', vim.lsp.buf.workspace_symbol },
    -- { 'n', '<leader>lh',  vim.lsp.buf.hover },
    -- { 'n', '<leader>ls',  vim.lsp.buf.signature_help },
    -- { 'n', '<leader>ln',  vim.lsp.buf.rename },
    -- { 'n', '<leader>la',  vim.lsp.buf.code_action },
    -- { 'n', '<leader>lf',  vim.lsp.buf.format },
    -- { 'n', '<leader>ltf', function()
    --     vim.b.disableFormatSave = not vim.b.disableFormatSave
    -- end },
}

for _, map in ipairs(mappings) do
    vim.keymap.set(unpack(map))
end
