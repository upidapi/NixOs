{
  # pkgs,
  # inputs,
  my_lib,
  config,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.suites.all;
in {
  options.modules.nixos.suites.all =
    mkEnableOpt "enables everything except the really user specific stuff";

  # TODO: split this into smaller parts
  config = mkIf cfg.enable {
    modules.nixos = {
      other = enable;

      # home-tunnel = enable;

      cli-apps = {
        less = enable;
        keepass = enable;
      };

      apps = {
        steam = enable;
      };

      system = {
        core = {
          fonts = enable;
          boot = enable;
          env = enable;
          locale = enable;
        };

        nix = {
          cfg-path = "/persist/nixos";

          cachix = enable;
          flakes = enable;
          gc = enable;
          nix-index = enable;
          misc = enable;
        };

        misc = {
          impermanence = enable;
          noshell = enable;
          sops = enable;
        };

        security = {
          sudo-rs = enable;
          openssh = enable;
        };
      };

      desktop = {
        sddm = enable;
        hyprland = enable;
      };

      hardware = {
        cpu.amd = enable;
        gpu.nvidia = enable;

        bth = enable;
        sound = enable;
        network = enable;
        keyboard = enable;
      };
    };
  };
}
