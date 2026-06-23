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
--
--


-- Close/open neotree on dap ui close/open
local neotree_was_open = false

local function is_neotree_open()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "neo-tree" then
      return true
    end
  end
  return false
end

dap.listeners.after.event_initialized["dapui_config"] = function()
  neotree_was_open = is_neotree_open()
  if neotree_was_open then
    vim.cmd("Neotree close")
  end
  dapui.open()
end

local function restore_layout_on_close()
  dapui.close()
  if neotree_was_open then
    vim.cmd("Neotree show") -- reopen without stealing cursor focus
    neotree_was_open = false
  end
end

dap.listeners.before.event_terminated["dapui_config"] = restore_layout_on_close
dap.listeners.before.event_exited["dapui_config"] = restore_layout_on_close
