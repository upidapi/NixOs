{pkgs, ...}: {
  imports = [
    #../packages/tuxedo-keyboard/tuxedo-keyboard.nix
    #../packages/tuxedo-control-center/tuxedo-control-center.nix
    ./tuxedo-drivers/tuxedo-drivers.nix
    ./tuxedo-rs.nix
  ];

  disabledModules = ["hardware/tuxedo-keyboard.nix"];

  hardware = {
    #  tuxedo-keyboard.enable = true;
    tuxedo-drivers.enable = true;
  };

  #services.udev.extraRules = builtins.readFile ../packages/tuxedo-drivers/99-z-tuxedo-systemd-fix.rules;
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "99-z-tuxedo-systemd-fix.rules";
      text = ''
        	    # Workaround for a systemd bug, that is causing a boot delay, when there are too many kbd_backlight devices.
        SUBSYSTEM=="leds", KERNEL=="*kbd_backlight*", TAG-="systemd"
        SUBSYSTEM=="leds", KERNEL=="*kbd_backlight", TAG+="systemd"
        SUBSYSTEM=="leds", KERNEL=="*kbd_backlight_1", TAG+="systemd"
        SUBSYSTEM=="leds", KERNEL=="*kbd_backlight_2", TAG+="systemd"
        SUBSYSTEM=="leds", KERNEL=="*kbd_backlight_3", TAG+="systemd"
      '';
      destination = "/etc/udev/rules.d/99-z-tuxedo-systemd-fix.rules";
    })
  ];

  environment.systemPackages = with pkgs; [
    #(config.boot.kernelPackages.callPackage ../packages/tuxedo-control-center {})
  ];

  #hardware.tuxedo-control-center = {
  #  enable = true;
  #};

  #hardware.tuxedo-rs = {
  #   enable = true;
  #   tailor-gui.enable = true;
  # };
}
