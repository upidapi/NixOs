
local nvim_tree_select = require('nvim-treesitter.incremental_selection')
local dap = require("dap")

local mappings = {
    -- open toggle term
    {"n", "<c-t>", "<Cmd>execute v:count . \"ToggleTerm\"<CR>"},

    {"n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>"},

    -- bind the key that is where : "usually" is to :
    {"n", "Ö", ":"},
    
    -- move one visual line with arrow keys
    {"i", "<up>", "<c-o>g<up>"},
    {"i", "<down>", "<c-o>g<down>"},
    {"vn", "<up>", "g<up>"},
    {"vn", "<down>", "g<down>"},

    -- exit terminal mode with esc
    {"t", "<Esc>", "<C-><C-n>"},

    -- format 
    {"n", "<F3>", function()
        vim.lsp.buf.format({ async = true })
    end},

    {"n", "<leader>d.", dap.run_last},
    {"n", "<leader>dC", dap.run_to_cursor},
    {"n", "<leader>dR", dap.restart},
    {"n", "<leader>db", dap.toggle_breakpoint},
    {"n", "<leader>dc", dap.continue},
    {"n", "<leader>di", dap.step_into},
    {"n", "<leader>dj", dap.step_over},
    {"n", "<leader>dk", dap.step_back},
    {"n", "<leader>do", dap.step_out},
    {"n", "<leader>dq", dap.terminate},
    {"n", "<leader>dr", dap.repl.toggle},
    {"n", "<leader>dvi", dap.down},
    {"n", "<leader>dvo", dap.up},
    {"n", "<leader>dh", require('dap.ui.widgets').hover},
    {"n", "<leader>du", require('dapui').toggle},

    {"n", "gnn", nvim_tree_select.init_selection},
    {"x", "grc", nvim_tree_select.scope_incremental},
    {"x", "grm", nvim_tree_select.node_decremental},
    {"x", "grn", nvim_tree_select.node_incremental},

    {"n", "<leader>fC", "<cmd> Telescope git_commits<CR>"},
    {"n", "<leader>fb", "<cmd> Telescope buffers<CR>"},
    {"n", "<leader>fc", "<cmd> Telescope git_bcommits<CR>"},
    {"n", "<leader>ff", "<cmd> Telescope find_files<CR>"},
    {"n", "<leader>fg", "<cmd> Telescope live_grep<CR>"},
    {"n", "<leader>fp", "<cmd> Telescope projects<CR>"},
    {"n", "<leader>fr", "<cmd> Telescope resume<CR>"},
    {"n", "<leader>fz", "<cmd> Telescope current_buffer_fuzzy_find<CR>"},

    {"n", "<leader>tr", "<cmd> Neotree reveal<CR>"},
    {"n", "<leader>tt", "<cmd> Neotree toggle<CR>"},
    {"n", "<leader>tu", "<cmd> Neotree<CR>"},
}


for _, map in ipairs(mappings) do
    vim.keymap.set(table.unpack(map))
end


