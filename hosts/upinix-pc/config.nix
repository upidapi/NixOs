{
  self,
  pkgs,
  mlib,
  const,
  inputs,
  config,
  ...
}: let
  inherit (const) keys;
  inherit (mlib) enable enableAnd;
in {
  system.stateVersion = "23.11";

  imports = [
    # i have the b650 but the config for it is here :)
    # fixes suspend issues
    inputs.nixos-hardware.nixosModules.gigabyte-b550
  ];

  sops.secrets."users/root".neededForUsers = true;
  sops.secrets."users/upidapi".neededForUsers = true;

  users.users = {
    upidapi = {
      isNormalUser = true;

      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirtd"
        "adbusers"
        "docker"
        "media"
        "minecraft"
      ];

      # mkpasswd "<password>" | wl-copy
      hashedPasswordFile = config.sops.secrets."users/upidapi".path;

      openssh.authorizedKeys.keys = [keys.users.upidapi];
    };

    debug = {
      isNormalUser = true;
      password = "";
      openssh.authorizedKeys.keys = [keys.users.upidapi];
    };

    debug-1 = {
      isNormalUser = true;
      password = "1";
      openssh.authorizedKeys.keys = [keys.users.upidapi];
    };

    root.hashedPasswordFile = config.sops.secrets."users/root".path;
  };

  # head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "4d23fd9d"; # req for zfs
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;

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

    misc.flatpak = enable;

    homelab = {
      media = enableAnd {
        jellyfin = enable;
        jellyseerr = enable;
        arr = enable;
        qbit = enable;
        cross-seed = enable;
      };

      infra = {
        tofu = enable;

        ddclient = enable;
        caddy = enable;
        authelia = enable;
      };

      services = {
        transfer-sh = enable;
        wg-easy = enable;
        homepage = enable;
        thelounge = enable;
      };

      games = {
        impostor = enable;
        necesse = enable;
        minecraft = enable;
      };
    };

    networking = {
      # wireguard.server = enable;
      # vpn.mullvad = {
      #   enable = true;
      #   createNamespace = true;
      # };

      vpn.namespaces = enableAnd {
        proton = true;
      };
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
