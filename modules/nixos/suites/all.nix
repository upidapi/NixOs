{
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
        misc = enable;
      };

      os = {
        boot = enable;

        graphical = {
          hyprland = enable;
          login = {
            greetd = enable;
          };
          xserver = enable;
        };

        environment = {
          fonts = enable;
          locale = enable;
          paths = enable;
          xdg = enable;
        };

        misc = {
          console = enable;
          impermanence = enable;
          noshell = enable;
          sops = enable;
          # prelockd = enable;
        };

        networking = {
          wifi = enable;
          iphone-tethering = enable;

          openssh = enable;

          firewall = {
            fail2ban = enable;
          };
        };

        services = {
          ntpd = enable;
          upower = enable;
          syncthing = enable;
          restic = enable;
        };

        virtualisation = {
          podman = enable;
          # vfio = enable;
          qemu = enable;
          waydroid = enable;
          distrobox = enable;
        };
      };

      security = {
        # too annoying cant use --preserve-env
        # sudo-rs = enable;
        cfg-perms = enable;
        sudo = enable;
      };

      other = enable;
    };
  };
}
