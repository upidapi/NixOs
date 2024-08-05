{
  my_lib,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) getExe;
  inherit (inputs.nvf.lib.nvim.lua) toLuaObject;
  inherit (my_lib.opt) enable;
in {
  programs.nvf = {
    /*
    modules.lspSources = {
      nixd = {
        package = pkgs.nixd;
        arguments = ["--semantic-tokens=false"];
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
        nix =
          enable
          // {
            lsp.enable = false;
          };
        go = enable;
        python = enable;
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
