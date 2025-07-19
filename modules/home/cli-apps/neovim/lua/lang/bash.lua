-- https://github.com/bash-lsp/bash-language-server
require("lspconfig").bashls.setup({})

local function set_group(base, group, table)
    for _, v in ipairs(group) do
        base[v] = table
    end
end

set_group(
    require("lint").linters_by_ft,
    { "bash", "sh", "zsh", "ksh" },
    { "shellcheck" }
)

set_group(require("conform").formatters_by_ft, { "bash", "sh" }, { "shfmt" })
