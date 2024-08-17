{
  pkgs,
  lib,
  my_lib,
  keys,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  system.stateVersion = "23.11";

  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    extraGroups = ["networkmanager" "wheel" "libvirtd"];
    hashedPassword = "$y$j9T$P.ANM.hAc1bqSR7fJWfkZ.$vUxY3KyPB65PR3uTBKwYCa7u6LvUquy47SeAPjgnjD9";

    openssh.authorizedKeys.keys = [keys.users.upidapi];
  };

  users.users.root.hashedPassword = "$y$j9T$9xMPUcZ6FDsmUAHnIlyk80$8bJB3zlzCf3VsqAfpxaJ9qBhLiDq3syabSj1n/xUH41";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems.zfs = lib.mkForce false;
    # fix issues with keyboard after suspend
    kernelParams = ["i8042.reset" "i8042.nomux" "i8042.nopnp" "i8042.noloo"];
  };

  # TODO: use "tuxedo-drivers"
  #  https://github.com/NixOS/nixpkgs/pull/293017

  /*
  # FIXME: enable when it works
  hardware = {
    tuxedo-keyboard = enable;
    tuxedo-rs = {
      enable = true;
      tailor-gui = enable;
    };
  };
  */

  /*
  # not tested but should use my custom pkg with my overrides
  boot.kernelPackages.tuxedo-keyboard = self'.packages.tuxedo-keyboard;

  # this does the "same"
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     tuxedo-keyboard = prev.tuxedo-keyboard.overrideAttrs (old: {
  #       patches =
  #         (old.patches or [])
  #         ++ [
  #           "${self}/parts/patches/tuxedo-keyboard.path"
  #         ];
  #     });
  #   })
  # ];
  */

  # https://bbs.archlinux.org/viewtopic.php?id=273039
  systemd.services.restart-usb-after-suspend = {
    enable = true;
    description = "";
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "restart-usb-inputs" ''
        # Reset the keyboard driver and USB mouse

        modprobe -r atkbd
        modprobe atkbd reset=1
        echo "Finished resetting the keyboard."

        # Reset every USB device, because we don't know in advance which port
        # the mouse is plugged into. Send errors to /dev/null to avoid
        # cluttering up the logs.
        for USB in /sys/bus/usb/devices/*/authorized; do
            eval "echo 0 > $USB" 2>/dev/null
            eval "echo 1 > $USB" 2>/dev/null
        done
        echo "Finished resetting USB inputs."
      '';
      CPUWeight = 500;
    };
    after = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    wantedBy = [
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
  };

  modules.nixos = {
    suites.all = enable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      monitors.monitors = {
        "desc:BOE 0x0C8E" = {
          width = 2560;
          height = 1600;
          refreshRate = 240;
          x = 0;
          y = 0;
          scale = 1.333333;

          workspace = 1;
          primary = true;
        };
      };
    };
  };
}
