{
  pkgs,
  lib,
  my_lib,
  keys,
  self',
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    ./tuxedo
  ];

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
    # maybe fix issues with keyboard after suspend
    kernelParams = [
      "atkbd.reset=1"
      "i8042.dumbkbd=1"
      "i8042.noaux=1"
      "i8042.noloop=1"
      "i8042.nomux=1"
      "i8042.nopnp=1"
      "i8042.reset=1"
    ];
  };

  # TODO: use "tuxedo-drivers"
  #  https://github.com/NixOS/nixpkgs/pull/293017

  # possible fix for suspend issues
  services.udev.extraRules = builtins.concatStringsSep "\n" (
    ["# Properly suspend the system."]
    ++ (
      map
      (device: ''SUBSYSTEM=="pci", ACTION=="add", ATTR{vendor}=="0x144d", ATTR{device}=="${device}", RUN+="${pkgs.runtimeShell} -c 'echo 0 > /sys/bus/pci/devices/$kernel/d3cold_allowed'"'')
      ["0xa80a" "0xa808"]
    )
  );

  /*
  nixpkgs.overlays = [
    (_: _: {
      inherit (self'.packages) tuxedo-keyboard;
    })
  ];

  nixpkgs.overlays = [ (_: super: {
      tuxedo-keyboard = super.tuxedo-keyboard.overrideAttrs (
        prev: {
          patches = (prev.patches or []) ++ [./tuxedo-keyboard.patch];
        }
      );
    })
  ];

  nixpkgs.overlays = [ (self: super: {
    picom = super.picom.overrideAttrs (prev: {
      version = "git";
      src = pkgs.fetchFromGitHub {
        owner = "yshui";
        repo = "picom";
        rev = "31e58712ec11b198340ae217d33a73d8ac73b7fe";
        sha256 = pkgs.lib.fakeSha256;
      };
    });
  }) ];
  */

  # FIXME: enable when it works
  hardware = {
    # tuxedo-keyboard = enable;
    tuxedo-rs = {
      enable = true;
      tailor-gui = enable;
    };
  };

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
