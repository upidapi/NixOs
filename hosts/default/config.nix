# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
# https://www.reddit.com/r/NixOS/comments/e3tn5t/reboot_after_rebuild_switch/
{
  # config,
  pkgs,
  lib,  
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.upidapi = {
    isNormalUser = true;
    description = "upidapi";
    extraGroups = ["networkmanager" "wheel"];
    shell = pkgs.nushell;
    initialPassword = "1";
    # packages = with pkgs; [
    #   # firefox
    # ];
  };
  

  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      {
        directory = "/etc/nixos";
        mode = "0777";
      }
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      { 
        directory = "/var/lib/colord"; 
        user = "colord"; 
        group = "colord"; 
        mode = "u=rwx,g=rx,o="; 
      }
    ];
    files = [
      # "/etc/machine-id"
      { 
        file = "/var/keys/secret_file"; 
        parentDirectory = { 
          mode = "u=rwx,g=,o="; 
          }; 
        }
    ];
  };

  /*
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount /dev/root_vg/root /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';  
  
  systemd.tmpfiles.rules = [
  "d /persist/home/ 0777 root root -" # create /persist/home owned by root
  "d /persist/home/upidapi 0700 upidapi users -" # /persist/home/<user> owned by that user
];

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist/system" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"  # where the nix config is
      "/var/log"  
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"  # wifi 
      
      # https://www.freedesktop.org/software/colord/specifics.html
      { 
        directory = "/var/lib/colord"; 
        user = "colord"; 
        group = "colord"; 
        mode = "u=rwx,g=rx,o="; 
      }
    ];

    files = [
      "/etc/machine-id"
      { 
        file = "/var/keys/secret_file"; 
        parentDirectory = { 
          mode = "u=rwx,g=,o="; 
        }; 
      }
    ];
  }; 
  */

  # required by home manager impermanance  
  programs.fuse.userAllowOther = true;

  # user.user.root.initialPassword = "1";

  modules.nixos = {
    core = enable;

    apps = {
      less = enable;
      # zsh = enable;
      # nushell = enable;
      steam = enable;
    };

    system = {
      fonts = enable;
      boot = enable;
      env = enable;
      locale = enable;
    };

    desktop.sddm = enable;

    hardware = {
      # cpu.amd = enable;
      # gpu.nvidia = enable;

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
    swww # wallpaper daemions
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout

    tree # show file system tree
    git

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
