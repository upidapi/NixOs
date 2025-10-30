{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.games.necesse;

  necesse-server =
    (import (fetchTarball {
        # Pick a specific nixpkgs commit from GitHub
        url = "https://github.com/NixOS/nixpkgs/archive/ae824da8858.tar.gz";
        sha256 = "sha256:0nm4b3ycdidgrn6vzzzxfs1gqwsiglvzls42xhylhpbgh5r4vp75";
        # You can get this URL from a commit page on GitHub
      }) {
        inherit (pkgs) system;
        config = {
          allowUnfree = true;
        };
      })
    .necesse-server;
in {
  options.modules.nixos.homelab.games.necesse = mkEnableOpt "";

  config = mkIf cfg.enable {
    systemd.services."necesse-server" = {
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        User = "upidapi";
        Group = "users";

        # WorkingDirectory = "/home/upidapi/persist/prog/projects/necesse-server";
        # ExecStart = "/home/upidapi/persist/prog/projects/necesse-server/run.sh";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "run-necesse-server";
          runtimeInputs = [
            necesse-server
            pkgs.curl
          ];
          text = ''
            #!/usr/bin/env nix-shell
            #! nix-shell -i bash
            # shellcheck shell=bash

            # nix-shell maintainers/scripts/update.nix --argstr package necesse-server

            # necesse-server -help

            echo "Necesse-server is avalible at"
            echo "guide: https://shockbyte.com/help/knowledgebase/articles/how-to-join-your-necesse-server"
            echo "ip: $(curl -4 ifconfig.me --silent)"
            echo "port: 6800"
            echo

            necesse-server -nogui -world 07024950463 -port 6800 -slots 20
          '';
        });
      };
    };
  };
}
