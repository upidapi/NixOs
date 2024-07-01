# A minimal config used as a intermediate step when installing my
# config. Provides a basic env for debugging and does a few things
# to make the full install quicker
# The most important thing is activating flakes since nixos-install
# cant really handle them well (in theory you can use --flake but
# that has many buggs)
{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware.nix
  ];

  nix.settings = {
    # flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # build cache servers
    substituters = [
      "https://cuda-maintainers.cachix.org"
      "https://cache.nixos.org/"
      "https://hyprland.cachix.org"
      "https://devenv.cachix.org"
    ];

    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "se";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  users.users.root.initialPassword = "";

  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    extraGroups = ["networkmanager" "wheel"];

    initialPassword = "";

    # packages = with pkgs; [
    #   firefox
    #   kate
    # ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = [
    pkgs.git
  ];

  system.stateVersion = "23.11"; # Did you read the comment?

  systemd.services.custom-nixos-installer = {
    description = "installs my nixos config";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      profile=$(cat /persist/nixos/profile-name.txt) &&
      nixos-rebuild switch --flake "/persist/nixos#$profile" &&
      rm /persist/nixos/profile.txt &&
      chown -R :wheel /persist/nixos &&
      chmod -R 770 /persist/nixos &&
      reboot
    '';
    wantedBy = ["multi-user.target"]; # starts after login
  };
}
