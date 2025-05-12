{
  pkgs,
  my_lib,
  keys,
  inputs,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  system.stateVersion = "23.11";

  imports = [
    # i have the b650 but the config for it is here :)
    # fixes suspend issues
    inputs.nixos-hardware.nixosModules.gigabyte-b550
  ];

  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    extraGroups = [
      "wheel"
      "networkmanager"
      "libvirtd"
      "adbusers"
      "docker"
    ];

    hashedPassword = "$y$j9T$EYMQdTmw82Nd2wnoDxrB10$OGquV37TGBUPTjhQAQ71xCMtmo3y0mnQiznUbME4UT3";

    openssh.authorizedKeys.keys = [keys.users.upidapi];
  };

  users.users.root.hashedPassword = "$y$j9T$kV/aEFz0la0QtThvK5Ghp1$oxghtnjsA0mSXrM62uY99l7ijDIN5tIFynkKhNcEOP0";

  # force the "correct" res, since one of my displays is smaller
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
    /*
    os.virtualisation.vfio.devices = [
       "10de:2182"
       "10de:1aeb"
       "10de:1aec"
       "10de:1aed"
    ];
    */

    os.services = {
      jellyfin = enable;
      ddclient = enable;
      caddy = enable;
    };

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      monitors.monitors = {
        # disable
        # https://github.com/hyprwm/Hyprland/issues/5958
        # https://github.com/hyprwm/Hyprland/issues/6032
        "Unknown-1" = {
          enabled = false;
          workspace = -1;
        };
        "desc:Dell Inc. DELL U2312HM 59DJP23QCZFL" = {
          # for some reason the names change when using sops
          # therefore use desc to match instead
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = -1920;
          y = 0;
          workspace = 1;
        };
        "desc:ASUSTek COMPUTER INC VG246H1A R2LMTF144267" = {
          width = 1920;
          height = 1080;
          refreshRate = 100;
          x = 0;
          y = 0;
          workspace = 2;
          primary = true;
        };
        "desc:AlgolTek Inc. 0x0001 0x434E3031" = {
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 1920;
          y = 0;
          workspace = 3;
        };
      };
    };
  };
}
