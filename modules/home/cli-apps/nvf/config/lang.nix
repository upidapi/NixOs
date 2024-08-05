{
  my_lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  programs.nvf = {
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
          nixos.expr = x "nixosConfigurations";
          home_manager.expr = x "homeConfigurations";
          darwin.expr = x "darwinConfigurations";
        };
        extra = true;
      };
    };

    settings.vim = {
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
