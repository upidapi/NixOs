-- if needed add more ft 
-- local sql_ft = { "sql", "mysql", "plsql" }

require("lint").linters_by_ft.sql = { "sqlfluff" }
require("conform").formatters_by_ft.sql= { "sqlfluff" }

require'lspconfig'.sqls.setup{
  -- ODO: 
  -- cmd = {"path/to/command", "-config", "path/to/config.yml"};
  -- ...
}
