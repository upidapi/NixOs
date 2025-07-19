require("conform").formatters["markdownlint-cli2"] = {
    condition = function(_, ctx)
        local diag = vim.tbl_filter(function(d)
            return d.source == "markdownlint"
        end, vim.diagnostic.get(ctx.buf))
        return #diag > 0
    end,
}

-- ["markdown-toc"] = {
--     condition = function(_, ctx)
--         for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
--             if line:find("<!%-%- toc %-%->") then
--                 return true
--             end
--         end
--     end,
-- },

require("conform").formatters_by_ft.markdown = {
    "prettierd",
    "markdownlint-cli2",
    -- "markdown-toc",
}

require("lint").linters_by_ft.markdown = {
    -- "markdownlint-cli"
}

require("lspconfig").marksman.setup({})
