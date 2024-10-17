{
  # explanations for i8042 options
  # https://lightrush.ndoytchev.com/random-1/i8042quirkoptions

  # similar issues
  # https://askubuntu.com/questions/1248701/laptop-ubuntu-20-04-integrated-keyboard-does-not-function-after-closing-the-lid
  # https://ubuntuforums.org/showthread.php?t=2224316

  # This fixes a bug where, sometimes after you un-suspend after suspending
  # through closing the lid (This doesn't happen when suspending manually)
  # the built in keyboard partially breaks (some keys, eg brightness upp /
  # down still work). The mousepad still works and external keyboards also
  # work without problem.

  # Fix keyboard not working on "TUXEDO Stellaris 15 Slim Gen6 AMD" after
  # suspend.
  # Based on https://github.com/torvalds/linux/commit/3870e2850b56306d1d1e435c5a1ccbccd7c59291
  # Can be removed once it is put into the kernel package you are using.
  boot.kernelParams = [
    "i8042.noloop=1" # Disable the AUX Loopback command while probing for the AUX port
    "i8042.nomux=1" # Don't check presence of an active multiplexing controller
    "i8042.nopnp=1" # Don't use ACPIPnP / PnPBIOS to discover KBD/AUX controllers
    "i8042.reset=1" # Reset the controller during init and cleanup
  ];

  # Another possibly fix that doesn't solve it
  # services.udev.extraRules = builtins.concatStringsSep "\n" (
  #   ["# Properly suspend the system."]
  #   ++ (
  #     map
  #     (device: ''SUBSYSTEM=="pci", ACTION=="add", ATTR{vendor}=="0x144d", ATTR{device}=="${device}", RUN+="${pkgs.runtimeShell} -c 'echo 0 > /sys/bus/pci/devices/$kernel/d3cold_allowed'"'')
  #     ["0xa80a" "0xa808"]
  #   )
  # );

  # Another possibly fix that doesn't solve it
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
}
