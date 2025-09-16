-- also config for c

-- SECTION: clang-lsp
-- local clangd_cap = require("lua.lsp.utils").capabilities
-- use same offsetEncoding as null-ls
-- NOTE: not doing this might break things
-- clangd_cap.offsetEncoding = { "utf-16" }
require("lspconfig").clangd.setup({
    -- capabilities = clangd_cap,
    -- cmd = { "/nix/store/kw7y8ysgzasbwxb8qw1a486s35nfdnlv-clang-tools-18.1.8/bin/clangd" }
})

local dap = require("dap")
require("dap").adapters["codelldb"] = {
    type = "server",
    port = "${port}",
    executable = {
        command = "codelldb",
        args = { "--port", "${port}" },
    },
}

-- FIXME: breaks nvim open
-- local base_cfg = {
--     name = "Launch file",
--     type = "codelldb",
--     request = "launch",
--     program = require("dap.utils").pick_file({
--         filter = ".*.out",
--     }),
--     cwd = "${workspaceFolder}",
--     stopOnEntry = false,
-- }
--
-- -- NOTE: has to be compiled with -ggdb
-- --  g++ -ggdb main.cpp -o main.out
-- dap.configurations.cpp = {
--     base_cfg,
--     vim.tbl_deep_extend("force", base_cfg, {
--         name = "Launch file, redirect stdio",
--         stdio = function()
--             return {
--                 -- vim.fn.input(
--                 --     "Path to input file: ", --
--                 --     vim.fn.getcwd() .. "/",
--                 --     "file"
--                 -- ),
--                 "inp.txt",
--                 nil,
--                 nil,
--             }
--         end,
--     }),
-- }
-- -- https://github.com/vadimcn/codelldb/blob/master/MANUAL.md#expressions
-- -- You can prefix things with /nat to call functions etc
--
-- dap.configurations.c = dap.configurations.cpp

-- for _, lang in ipairs({ "c", "cpp" }) do
--     dap.configurations[lang] = {
--         {
--             type = "codelldb",
--             request = "launch",
--             name = "Launch file",
--             program = function()
--                 return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
--             end,
--             cwd = "${workspaceFolder}",
--         },
--         {
--             type = "codelldb",
--             request = "attach",
--             name = "Attach to process",
--             pid = require("dap.utils").pick_process,
--             cwd = "${workspaceFolder}",
--         },
--     }
-- end
