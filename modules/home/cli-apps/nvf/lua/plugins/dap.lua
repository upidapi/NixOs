local dap = require("dap")
vim.fn.sign_define(
    "DapBreakpoint", {
        text = "🛑",
        texthl = "ErrorMsg",
        linehl = "",
        numhl = ""
    }
)


local dapui = require("dapui")
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end
