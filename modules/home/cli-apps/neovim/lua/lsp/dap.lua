local dap = require("dap")

for name, sign in pairs(require("lua.icons").dap) do
    sign = type(sign) == "table" and sign or { sign }
    vim.fn.sign_define("Dap" .. name, {
        text = sign[1],
        texthl = sign[2] or "DiagnosticInfo",
        linehl = sign[3],
        numhl = sign[3],
    })
end

-- setup dap config by VsCode launch.json file
local vscode = require("dap.ext.vscode")
local json = require("plenary.json")
vscode.json_decode = function(str)
    return vim.json.decode(json.json_strip_comments(str))
end

vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

require("nvim-dap-virtual-text").setup()

local dapui = require("dapui")
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end

-- dap.listeners.before.event_terminated["dapui_config"] = function()
--     dapui.close()
-- end
--
-- dap.listeners.before.event_exited["dapui_config"] = function()
--     dapui.close()
-- end

-- NOTE: configs here https://github.com/mfussenegger/nvim-dap
--
-- https://igorlfs.github.io/neovim-cpp-dbg
