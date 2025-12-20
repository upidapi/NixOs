{
  mlib,
  config,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt enableAnd;
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
        # print = enable; # BROKEN: borked
      };

      misc = {
        boot = enable;

        impermanence = enable;
        nix-ld = enable;
        sops = enable;

        programs = {
          dotnet = enable;
          steam = enable;
        };

        services = {
          ntpd = enable;
          syncthing = enable;
          restic = enable;
          # caddy = enable;
        };

        nix = {
          cfg-path = "/persist/nixos";

          nh = enable;
          gc = enable;
          cachix = enable;
          githubToken = enable;
          misc = enable;
        };
      };

      env = {
        fonts = enable;
        locale = enable;
        paths = enable;
        xdg = enable;

        console = enable;
        noshell = enable;

        login = {
          # NOTE: greetd doesn't call it with env vars, so i have to do this
          command = "zsh -c Hyprland";
          autoLogin = false;
          greetd = enable;
        };

        graphical = {
          hyprland = enable;
          # xserver = enable;
        };
      };

      os = {
        primaryUser = "upidapi";
        adminUser = "upidapi";
      };

      networking = {
        wifi = enable;
        iphone-tethering = enable;

        misc = enable;
        openssh = enable;

        vpn = {
          proton = enable;
        };

        firewall = {
          fail2ban = enable;
          ports = enable;
        };
      };

      virtualisation = {
        podman = enable;
        # vfio = enable;
        qemu = enable;
        # waydroid = enable;
        distrobox = enable;
      };

      security = {
        # too annoying cant use --preserve-env
        # sudo-rs = enable;
        # keyring = enable;
        cfg-perms = enable;
        sudo = enable;
      };

      other = enable;
    };
  };
}
