{
  # config,
  pkgs,
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

  # force the correct res, since the kernel thinks one of my disaplys is samller
  # otherwise it selects the smaller res
  systemd.services.console-fbset = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      # ExecStartPost = "${pkgs.util-linux}/bin/setterm -resize";
      # ExecStartPre = "/run/current-system/sw/bin/sleep 15";
      ExecStart = "${pkgs.fbset}/bin/fbset -xres 1920 -yres 1080";
      # TTYPath = "/dev/console";
      # StandardOutput = "tty";
      # StandardInput = "tty-force";
    };
    wantedBy = ["multi-user.target"];
    # environment = { TERM = "linux"; };
  };

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
          name = "desc:Dell Inc. DELL U2312HM 59DJP23QCZFL";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = -1920;
          y = 0;
          workspace = 1;
        }
        {
          name = "desc:ASUSTek COMPUTER INC VG246H1A R2LMTF144267";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 0;
          y = 0;
          workspace = 2;
          primary = true;
        }
        {
          name = "desc:AlgolTek Inc. 0x0001 0x434E3031";
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
