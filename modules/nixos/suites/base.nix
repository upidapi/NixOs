{
  mlib,
  config,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt;
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
    mkEnableOpt "";

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
        sops = enable;
        nix-ld = enable;
        appimage = enable;

        services = {
          ntpd = enable;
          syncthing = enable;
          restic = enable;
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

      os = {
        primaryUser = "upidapi";
        adminUser = "upidapi";
      };

      env = {
        fonts = enable;
        locale = enable;
        paths = enable;
        xdg = enable;

        console = enable;
        noshell = enable;
      };

      security = {
        # too annoying cant use --preserve-env
        # sudo-rs = enable;
        # keyring = enable;
        cfg-perms = enable;
        sudo = enable;
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
        # qemu = enable;
        # waydroid = enable;
        distrobox = enable;
      };

      other = enable;
    };
  };
}
