{
  mlib,
  config,
  lib,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf mkDefault;
  cfg = config.modules.nixos.suites.home;
  enable = {
    enable = mkDefault true;
  };
  # disable = {
  #   enable = mkDefault false;
  # };
in {
  options.modules.nixos.suites.home =
    mkEnableOpt "";

  config = mkIf cfg.enable {
    modules.nixos = {
      env = {
        login = {
          # NOTE: greetd doesn't call it with env vars, so i have to do this
          command = "zsh -c start-hyprland";
          autoLogin = false;
          greetd = enable;
        };

        graphical = {
          hyprland = enable;
          # xserver = enable;
        };
      };

      virtualisation = {
        # podman = enable;
        # vfio = enable;
        qemu = enable;
        # waydroid = enable;
        # distrobox = enable;
      };

      misc = {
        flatpak = enable;

        programs = {
          dotnet = enable;
          steam = enable;
        };
      };
    };
  };
}
