-------------- lsp ----------------
---
vim.lsp.config("nixd", {
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            formatting = {
                command = { "alejandra" },
            },
            options = {
                --

                -- REF: https://kokada.dev/blog/make-nixd-module-completion-to-work-anywhere-with-flakes/
                nixos = {
                    expr = [[
                        (
                          let
                            pkgs = import <nixpkgs> { };
                          in
                          (pkgs.lib.evalModules {
                            modules = (import <nixpkgs/nixos/modules/module-list.nix>) ++ [
                              ({ ... }: { nixpkgs.hostPlatform = builtins.currentSystem; })
                            ];
                          })
                        ).options
                    ]],
                },

                -- FIXME: seams to only work with nixos modules
                --   may be because im using hm as a nixos module
                -- home_manager = {
                --     expr = [[
                --         (
                --           let
                --             pkgs = import "${inputs.nixpkgs}" { };
                --             lib = import "${inputs.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib;
                --           in
                --           (lib.evalModules {
                --             modules = (import "${inputs.home-manager}/modules/modules.nix") {
                --               inherit lib pkgs;
                --               check = false;
                --             };
                --           })
                --         ).options
                --     ]],
                -- },

                -- REF: https://github.com/EmergentMind/nix-config/blob/dev/home/ta/common/core/nixvim/plugins/lspconfig.nix#L48
                -- nixos = {
                --     expr = [[
                --         with builtins;
                --           rec {
                --             getFirst = x: head (attrValues x);
                --
                --             flake = getFlake (getEnv "NIXOS_CONFIG_PATH");
                --
                --             nixos = getFirst flake.nixosConfigurations;
                --
                --             hm = getFirst nixos.config.home-manager.users;
                --           }
                --           .nixos
                --           .options
                --     ]],
                -- },
                -- home_manager = {
                --     expr = [[
                --         with builtins;
                --           rec {
                --             getFirst = x: head (attrValues x);
                --
                --             flake = getFlake (getEnv "NIXOS_CONFIG_PATH");
                --
                --             nixos = getFirst flake.nixosConfigurations;
                --
                --             hm = getFirst flake.homeConfigurations;
                --           }
                --           .hm
                --           .options
                --     ]],
                -- },

                -- flake_parts = {
                -- expr = 'let flake = builtins.getFlake (builtins.getEnv "NIXOS_CONFIG_PATH"); in flake.debug.options // flake.currentSystem.options',
                -- },
            },
        },
    },
})
vim.lsp.enable("nixd")

-- /nix/store/bziskf2rm9wks5fqpjaaywpldm9bpi6g-deadnix-1.2.1/bin/deadnix
-- /nix/store/pkqp4is8aybllw37406hb3n0081jdhgq-statix-0.5.8/bin/statix
require("lint").linters_by_ft.nix = { "deadnix", "statix" }
require("conform").formatters_by_ft.nix = { "alejandra" }
