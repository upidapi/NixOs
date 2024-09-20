{
  config,
  lib,
  my_lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.apps.vscode;
  extensions = inputs.nix-vscode-extensions.extensions.${pkgs.system};
in {
  options.modules.home.apps.vscode =
    mkEnableOpt
    "Whether or not to enable vscode.";

  config = mkIf cfg.enable {
    stylix.targets.vscode.enable = false;

    home.packages = with pkgs; [
      # maybe do this on project level
      nodejs_22
      typescript
    ];

    programs.vscode = {
      enable = true;
      extensions =
        with extensions.vscode-marketplace; [
          vscodevim.vim

          eamodio.gitlens

          # JavaScript, React
          dbaeumer.vscode-eslint
          esbenp.prettier-vscode
          firefox-devtools.vscode-firefox-debug

          # Git
          donjayamanne.githistory

          # Go
          golang.go

          # python
          ms-python.debugpy
          ms-python.python

          # rust
          rust-lang.rust-analyzer

          # cpp (lldb)
          vadimcn.vscode-lldb

          # Yaml
          redhat.vscode-yaml
        ]
        /*
             ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "Ruby";
            publisher = "rebornix";
            version = "0.28.1";
            sha256 = "179g7nc6mf5rkha75v7rmb3vl8x4zc6qk1m0wn4pgylkxnzis18w";
          }
          {
            name = "Nix";
            publisher = "bbenoist";
            version = "1.0.1";
            sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
          }
          {
            name = "vscode-elixir";
            publisher = "mjmcloug";
            version = "1.1.0";
            sha256 = "0kj7wlhapkkikn1md8cknrffrimk0g0dbbhavasys6k3k7pk2khh";
          }
          {
            name = "elixir-ls";
            publisher = "JakeBecker";
            version = "0.9.0";
            sha256 = "1qz8jxpzanaccd5v68z4v1344kw0iy671ksi1bmpyavinlxdkmr8";
          }
          {
            name = "solargraph";
            publisher = "castwide";
            version = "0.23.0";
            sha256 = "0ivawyq16712j2q4wic3y42lbqfml5gs24glvlglpi0kcgnii96n";
          }
          {
            name = "react-proptypes-generate";
            publisher = "suming";
            version = "1.7.6";
            sha256 = "0rfvk2f1c6b24fpdpk4f2kqi32h5np1pwij62bh872ividhs3s3l";
          }
          {
            name = "vscode-typescript-tslint-plugin";
            publisher = "ms-vscode";
            version = "1.3.3";
            sha256 = "1xjspcmx5p9x8yq1hzjdkq3acq52nilpd9bm069nsvrzzdh0n891";
          }
          {
            name = "rainbow-csv";
            publisher = "mechatroner";
            version = "2.0.0";
            sha256 = "0wjlp6lah9jb0646sbi6x305idfgydb6a51pgw4wdnni02gipbrs";
          }
          {
            name = "rust";
            publisher = "rust-lang";
            version = "0.7.8";
            sha256 = "039ns854v1k4jb9xqknrjkj8lf62nfcpfn0716ancmjc4f0xlzb3";
          }
          # {
          #   name = "";
          #   publisher = "";
          #   version = "";
          #   sha256 = "0000000000000000000000000000000000000000000000000000";
          # }
        ]
        */
        ;
    };
  };
}
