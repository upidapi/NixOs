{
  my_lib,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) getExe;
  inherit (inputs.nvf.lib.nvim.lua) toLuaObject;
  inherit (inputs.nvf.lib.nvim.dag) entryAfter;
  inherit (my_lib.opt) enable;
in {
  programs.nvf = {
    /*
    modules.lspSources = {
      nixd = {
        package = pkgs.nixd;
        arguments = []; # ["--semantic-tokens=false"];
        settings = let
          x = y: ''
            let
              flake = builtins.getFlake (
                "git+file://" + builtins.toString ./.
              );
              configs = flake.${y};
            in (builtins.head (builtins.attrValues configs)).options
          '';
        in {
          nixpkgs.expr = "import <nixpkgs> {}";
          options = {
            # nixos.expr = x "nixosConfigurations";
            # home_manager.expr = x "homeConfigurations";
            # add if i actually have a darwin output
            # darwin.expr = x "darwinConfigurations";
          };
        };
        extra = true;
        # extra = abort (builtins.attrValues (builtins.getFlake ("git+file://" + builtins.toString ./.)));
      };
    };
    */

    settings.vim = {
      /*
      extraPackages = [pkgs.nixd];
      pluginRC.nixd-manual = entryAfter ["lspconfig"] ''
          local on_attach = function(bufnr)
            vim.api.nvim_create_autocmd("CursorHold", {
              buffer = bufnr,
              callback = function()
                local opts = {
                  focusable = false,
                  close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
                  border = "rounded",
                  source = "always",
                  prefix = " ",
                  scope = "line",
                }
                vim.diagnostic.open_float(nil, opts)
              end,
            })
          end

          lspconfig.nixd.setup({
            on_attach = on_attach(),.
            capabilities = capabilities,
            settings = {
                nixd = {
                    nixpkgs = {
                        expr = "import <nixpkgs> { }",
                    },
                    formatting = {
                        command = { "nixpkgs-fmt" },
                    },
                    options = {
                        nixos = {
                            expr = '(builtins.getFlake "/persist/nixos").nixosConfigurations.upinix-pc.options',
                        },
                    },
                },
            },
        })
      '';
      */
      /*
      lsp.lspconfig.sources.nixd_test = ''
        lspconfig.nixd.setup {
          capabilities = capabilities,
          cmd = ${toLuaObject ([(getExe pkgs.nixd)] ++ ["--semantic-tokens=false"])},
          settings = {
            nixd = ${toLuaObject {
          nixpkgs.expr = "import <nixpkgs> {}";
        }},
          },
        }
      '';
      */

      /*
      programs.nvf.modules.lspSources.ruff-server = {
        package = pkgs.ruff;
        settings =
        arguments = [

        ];

      };
      */

      lsp.lspconfig.sources.ruff = let
        package = pkgs.ruff;
        cmd =
          [(getExe package)]
          ++ [
            "server"
            "--preview"
            "--config"
            "${../cfg-files/ruff.toml}"
            # "select = [ \"ALL\" ]"
          ];
      in
        /*
        lua
        */
        ''
          require('lspconfig').ruff.setup {
            trace = 'messages',
            init_options = {
              settings = {
                logLevel = 'debug',
              }
            },
            cmd = ${toLuaObject cmd},
            settings = {

            },
          }
        '';

      languages = {
        enableDAP = true;
        enableLSP = true;
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        # TODO: add lang run

        markdown = enable;

        html = enable;
        css = enable;
        tailwind = enable;
        ts = enable; # also adds js support

        # TODO: nixd
        nix = enable;
        # // {
        #   lsp.enable = false;
        # };
        go = enable;
        python = {
          enable = true;
          lsp.enable = false;
        };
        bash = enable;
        sql = enable;

        lua = {
          enable = true;
          lsp.neodev.enable = true;
        };

        rust = {
          enable = true;
          crates.enable = true;
        };

        clang = {
          enable = true;
          lsp = {
            enable = true;
            server = "clangd";
          };
        };
      };
    };
  };
}
