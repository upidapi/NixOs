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

  # desktop env
  programs.hyprland = {
    enable = true;
    # nvidiaPatches = true;
    xwayland.enable = true;
  };

  hardware = {
    opengl = {
      enable = true;
      # driSupport = true;
    };

    # most wayland compositors need this
    nvidia.modesetting.enable = true;
  };
  
  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

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
      nixos-cfg-path = "/perist/full-config";
      
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
      # nushell = enable;
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
}
