-------------- lsp ----------------
require("lspconfig").nixd.setup({
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            formatting = {
                command = { "alejandra" },
            },
            options = {
                -- REF: https://github.com/EmergentMind/nix-config/blob/dev/home/ta/common/core/nixvim/plugins/lspconfig.nix#L48
                --
                nixos = {
                    expr = [[
                        with builtins;
                          rec {
                            getFirst = x: head (attrValues x);

                            flake = getFlake (getEnv "NIXOS_CONFIG_PATH");

                            nixos = getFirst flake.nixosConfigurations;

                            hm = getFirst nixos.config.home-manager.users;
                          }
                          .nixos
                          .options
                    ]],
                },

                -- home_manager = {
                --     expr = [[
                --         with builtins; (head (attrValues (
                --             (getflake (getenv "nixos_config_path")).homeconfigurations
                --         ))).options
                --     ]],
                -- },

                -- flake_parts = {
                -- expr = 'let flake = builtins.getFlake (builtins.getEnv "NIXOS_CONFIG_PATH"); in flake.debug.options // flake.currentSystem.options',
                -- },
            },
        },
    },
})

-- /nix/store/bziskf2rm9wks5fqpjaaywpldm9bpi6g-deadnix-1.2.1/bin/deadnix
-- /nix/store/pkqp4is8aybllw37406hb3n0081jdhgq-statix-0.5.8/bin/statix
require("lint").linters_by_ft.nix = { "deadnix", "statix" }
