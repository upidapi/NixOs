-- if needed add more ft
-- local sql_ft = { "sql", "mysql", "plsql" }

-- require("lint").linters_by_ft.sql = { "sqlfluff" }
-- require("conform").formatters_by_ft.sql = { "sqlfluff" }

-- require("lspconfig").sqls.setup({
--     -- cmd = {"path/to/command", "-config", "path/to/config.yml"};
--     -- ...
-- })

require("dbee").setup({
    sources = {
        require("dbee.sources").MemorySource:new({
            {
                name = "Telefonid local",
                type = "sqlserver",
                url = "jdbc:sqlserver://localhost:1433;databaseName=TelefonIDSQL;user=sa;password=YourStrong@Passw0rd;trustServerCertificate=True",
            },
            -- you cant use ad login in dbee
            -- {
            --     name = "Telefonid dev",
            --     type = "sqlserver",
            --     url = "jdbc:sqlserver://telefonid-sqlserver-sc-dev.database.windows.net:1433;databaseName=telefonid-generalsqldb-sc-dev;authentication=ActiveDirectoryMSI",
            -- },
            -- ...
        }),
        -- export DBEE_CONNECTIONS='[
        --     {
        --         "name": "DB from env",
        --         "url": "username:password@tcp(host)/database-name",
        --         "type": "mysql"
        --     }
        -- ]'
        require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
        require("dbee.sources").FileSource:new(
            vim.fn.stdpath("cache") .. "/dbee/persistence.json"
        ),
    },
})

-- sqlserver://<server>:<port>/<database> authentication=ActiveDirectoryInteractive
-- sqlserver://telefonid-sqlserver-sc-dev.database.windows.net:1433/telefonid-generalsqldb-sc-dev?authentication=ActiveDirectoryMSI
--
-- use %40 for @ symbols in password etc
-- lua vim.g.db = "sqlserver://sa:YourStrong%40Passw0rd@localhost:1433/TelefonIDSQL"
-- DB
