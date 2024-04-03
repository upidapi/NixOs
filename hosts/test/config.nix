# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# https://www.reddit.com/r/NixOS/comments/e3tn5t/reboot_after_rebuild_switch/
{
  # config,
  pkgs,
  # lib,
  # inputs,
  # inputs',
  # self,
  # self',
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable;
in {
  imports = [
    # Include the results of the hardware scan.
    # inputs.home-manager.nixosModules.default
    ./hardware.nix
  ];

  networking.hostName = "upidapi-nix-pc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking

  networking.networkmanager.enable = true;

  # environment.variables = {
  #   WLR_NO_HARDWARE_CURSORS = "1";
  #   LIBVA_DRIVER_NAME = "nvidia";
  #   XDG_SESSION_TYPE = "wayland";
  #   GBM_BACKEND = "nvidia-drm";
  #   # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";

    # make a cfg-editor group that makes it so that a user
    # can edit the config
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.zsh;
    initialPassword = "1";
    # packages = with pkgs; [
    #   # firefox
    # ];
  };

  # user.user.root.initialPassword = "1";

  modules.nixos = {
    core = {
      nixos-cfg-path = "/persist/full-config";

      cachix = enable;
      flakes = enable;
      gc = enable;
      sops = enable;
    };

    cli-apps = {
      less = enable;
      zsh = enable;
    };

    apps = {
      steam = enable;
    };

    system = {
      impermanence = enable;
      fonts = enable;
      boot = enable;
      env = enable;
      locale = enable;
    };

    desktop.sddm = enable;

    hardware = {
      cpu.amd = enable;
      gpu.nvidia = enable;

      bth = enable;
      sound = enable;
      monitors = [
        {
          name = "DVI-D-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 0;
          y = 0;
          workspace = 1;
        }
        {
          name = "HDMI-A-1";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 1920;
          y = 0;
          primary = true;
          workspace = 2;
        }
        {
          name = "HDMI-A-2";
          width = 1920;
          height = 1080;
          refreshRate = 60;
          x = 3840;
          y = 0;
          workspace = 3;
        }
      ];
    };
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  /*

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty # terminal

    # grapejuice

    tree # show file system tree
    # git
    age

    python3
  ];
  */

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  # for flakes
  # nix.settings.experimental-features = ["nix-command" "flakes"];

  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;

  /*
     modules.nixos.core.nixos-cfg-path = "/persist/full-config";
  modules.nixos.hardware.monitors = [
    {
      name = "DVI-D-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 0;
      y = 0;
      workspace = 1;
    }
    {
      name = "HDMI-A-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 1920;
      y = 0;
      primary = true;
      workspace = 2;
    }
    {
      name = "HDMI-A-2";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      x = 3840;
      y = 0;
      workspace = 3;
    }
  ];
  */

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  /*
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

  # desktop env
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  /*
     x = {
    enable = true; # enables support for Bluetooth
    powerOnBoot = true; # powers up the default Bluetooth controller on boot
    settings = {
      General = {
        Experimental = "true";
        ControllerMode = "bredr";
        AutoEnable = "true";
      };
    };
  };
  */

  /*
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  services.blueman.enable = true;

  hardware = {
    opengl.enable = true;

    # most wayland compositors need this
    nvidia.modesetting.enable = true;
  };

  # hint electron apps that you're using wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Configure keymap in X11
  services.xserver = {
    layout = "se";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      # git
    ];
  };

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # handles desktop programs interactions
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kitty # remove when i can config the hyprland.conf
    alacritty

    rofi-wayland

    git

    dunst # notifications
    libnotify # notofication dep

    waybar # a bar (i think the top thing)

    swww # wallpaper daemions
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
  ];

  # setup neovim as the desfault editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  environment.variables.EDITOR = "nvim";
  */
}
