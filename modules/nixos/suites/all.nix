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
    mkEnableOpt "enables everything except for the hardware specific stuff";

  # TODO: split this into smaller parts
  config = mkIf cfg.enable {
    modules.nixos = {
      hardware = {
        bth = enable;
        keyboard = enable;
        sound = enable;
        video = enable;
      };

      misc.steam = enable;

      nix = {
        cfg-path = "/persist/nixos";

        cachix = enable;
        flakes = enable;
        gc = enable;
        nix-index = enable;
        misc = enable;
      };

      os = {
        boot = enable;

        graphical = {
          hyprland = enable;
          login = {
            greetd = enable;
            # sddm = enable;
          };
          xserver = enable;
        };

        environment = {
          fonts = enable;
          locale = enable;
          paths = enable;
          vars = enable;
        };

        misc = {
          console = enable;
          impermanence = enable;
          noshell = enable;
          sops = enable;
        };

        networking =
          enable
          // {
            openssh = enable;

            firewall = {
              fail2ban = enable;
            };
          };

        services = {
          ntpd = enable;
          upower = enable;
          syncthing = enable;
        };
      };

      security = {
        sudo-rs = enable;
      };

      other = enable;
    };
  };
}
