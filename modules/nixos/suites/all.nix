{
  mlib,
  config,
  lib,
  ...
}: let
  inherit (mlib.opt) mkEnableOpt enableAnd;
  inherit (lib) mkIf mkDefault;
  cfg = config.modules.nixos.suites.all;
  enable = {
    enable = mkDefault true;
  };
  # disable = {
  #   enable = mkDefault false;
  # };
in {
  options.modules.nixos.suites.all =
    mkEnableOpt "enables everything except for the hardware specific stuff";

  # could split this into parts when (or if) needed
  config = mkIf cfg.enable {
    modules.nixos = {
      hardware = {
        bth = enable;
        keyboard = enable;
        sound = enable;
        video = enable;
      };

      misc = {
        steam = enable;
        dotnet = enable;
      };

      nix = {
        cfg-path = "/persist/nixos";

        cachix = enable;
        flakes = enable;
        gc = enable;
        misc = enable;
      };

      os = {
        primaryUser = "upidapi";
        adminUser = "upidapi";

        boot = enable;

        env = {
          fonts = enable;
          locale = enable;
          paths = enable;
          xdg = enable;

          login = {
            # NOTE: when running Hyprland directly the env vars fail to load.
            #  So o I have to run it in a shell to access the env vars.
            command = "zsh -c Hyprland";
            autoLogin = false;
            greetd = enable;
          };

          graphical = {
            hyprland = enable;
            # xserver = enable;
          };
        };

        misc = {
          console = enable;
          impermanence = enable;
          noshell = enable;
          nix-ld = enable;
          sops = enable;
          # prelockd = enable;
        };

        networking = {
          wifi = enable;
          iphone-tethering = enable;

          openssh = enable;
          mullvad = enable;

          firewall = {
            fail2ban = enable;
            ports = enable;
          };
        };

        services = {
          ntpd = enable;
          upower = enable;
          syncthing = enable;
          restic = enable;
          # caddy = enable;
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
