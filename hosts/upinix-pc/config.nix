{
  #  config,
  # pkgs,
  # lib,
  # inputs,
  # inputs',
  # self,
  # self',
  my_lib,
  keys,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  system.stateVersion = "23.11"; # Did you read the comment?

  # TODO: factor out this into some module

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    extraGroups = ["networkmanager" "wheel" "libvirtd"];
    hashedPassword = "$y$j9T$EYMQdTmw82Nd2wnoDxrB10$OGquV37TGBUPTjhQAQ71xCMtmo3y0mnQiznUbME4UT3";

    openssh.authorizedKeys.keys = [keys.users.admin];
  };

  users.users.root.hashedPassword = "$y$j9T$kV/aEFz0la0QtThvK5Ghp1$oxghtnjsA0mSXrM62uY99l7ijDIN5tIFynkKhNcEOP0";

  modules.nixos = {
    suites.all = enable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      monitors = [
        # disable
        # https://github.com/hyprwm/Hyprland/issues/5958
        # https://github.com/hyprwm/Hyprland/issues/6032
        {
          name = "Unknown-1";
          enabled = false;
          workspace = -1;
        }
        {
          # for some reason the names change by sops

          # use desc to match insted
          name = "DVI-D-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = -1920;
          y = 0;
          primary = true;
          workspace = 1;
        }
        {
          name = "DP-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 0;
          y = 0;
          workspace = 2;
        }
        {
          name = "HDMI-A-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 1920;
          y = 0;
          workspace = 3;
        }
      ];
    };
  };
}
