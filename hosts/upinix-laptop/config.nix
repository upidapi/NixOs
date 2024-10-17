{
  pkgs,
  lib,
  my_lib,
  keys,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    # ./tuxedo
  ];

  system.stateVersion = "23.11";

  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "adbusers"
    ];
    hashedPassword = "$y$j9T$P.ANM.hAc1bqSR7fJWfkZ.$vUxY3KyPB65PR3uTBKwYCa7u6LvUquy47SeAPjgnjD9";

    openssh.authorizedKeys.keys = [keys.users.upidapi];
  };

  users.users.root.hashedPassword = "$y$j9T$9xMPUcZ6FDsmUAHnIlyk80$8bJB3zlzCf3VsqAfpxaJ9qBhLiDq3syabSj1n/xUH41";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems.zfs = lib.mkForce false;
    # https://askubuntu.com/questions/1248701/laptop-ubuntu-20-04-integrated-keyboard-does-not-function-after-closing-the-lid
    # https://lightrush.ndoytchev.com/random-1/i8042quirkoptions
    # https://ubuntuforums.org/showthread.php?t=2224316

    # This fixes a bug where, sometimes after you un-suspend after suspending
    # through closing the lid (This doesn't happen when suspending manually)
    # the built in keyboard partially breaks (some keys, eg brightness upp /
    # down still work). The mousepad still works and external keyboards also
    # work without problem.

    # Fix keyboard not working on "TUXEDO Stellaris 15 Slim Gen6 AMD" after
    # suspend.
    # Based on https://github.com/torvalds/linux/commit/3870e2850b56306d1d1e435c5a1ccbccd7c59291
    kernelParams = [
      # "i8042.direct=1" # Put keyboard port into non-translated mode
      # "i8042.dumbkbd=1" # Pretend that controller can only read data from keyboard and cannot control its state (Don't attempt to blink the leds)
      # "i8042.noaux=1" # Don't check for auxiliary (== mouse) port
      # "i8042.nokbd=1" # Don't check/create keyboard port
      "i8042.noloop=1" # Disable the AUX Loopback command while probing for the AUX port
      "i8042.nomux=1" # Don't check presence of an active multiplexing controller
      "i8042.nopnp=1" # Don't use ACPIPnP / PnPBIOS to discover KBD/AUX controllers
      "i8042.reset=1" # Reset the controller during init and cleanup
      # "i8042.unlock=1" # Unlock (ignore) the keylock
    ];
  };

  # possibly fixes suspend issues with keyboard
  # services.udev.extraRules = builtins.concatStringsSep "\n" (
  #   ["# Properly suspend the system."]
  #   ++ (
  #     map
  #     (device: ''SUBSYSTEM=="pci", ACTION=="add", ATTR{vendor}=="0x144d", ATTR{device}=="${device}", RUN+="${pkgs.runtimeShell} -c 'echo 0 > /sys/bus/pci/devices/$kernel/d3cold_allowed'"'')
  #     ["0xa80a" "0xa808"]
  #   )
  # );

  # possibly fixes suspend issues with keyboard
  # https://bbs.archlinux.org/viewtopic.php?id=273039
  # systemd.services.restart-usb-after-suspend = {
  # enable = true;
  # description = "";
  # serviceConfig = {
  #    Type = "simple";
  #    ExecStart = pkgs.writeShellScript "restart-usb-inputs" ''
  #      # Reset the keyboard driver and USB mouse
  #
  #      modprobe -r atkbd
  #      modprobe atkbd reset=1
  #      echo "Finished resetting the keyboard."
  #
  #      # Reset every USB device, because we don't know in advance which port
  #      # the mouse is plugged into. Send errors to /dev/null to avoid
  #      # cluttering up the logs.
  #      for USB in /sys/bus/usb/devices/*/authorized; do
  #          eval "echo 0 > $USB" 2>/dev/null
  #          eval "echo 1 > $USB" 2>/dev/null
  #      done
  #      echo "Finished resetting USB inputs."
  #    '';
  #    CPUWeight = 500;
  #  };
  #  after = [
  #    "suspend.target"
  #    "hibernate.target"
  #    "hybrid-sleep.target"
  #    "suspend-then-hibernate.target"
  #  ];
  #  wantedBy = [
  #    "suspend.target"
  #    "hibernate.target"
  #    "hybrid-sleep.target"
  #    "suspend-then-hibernate.target"
  #  ];
  # };

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
