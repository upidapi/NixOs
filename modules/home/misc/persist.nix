{
  config,
  mlib,
  lib,
  inputs,
  ...
}: let
  inherit (mlib) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.home.misc.persist;
in {
  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  options.modules.home.misc.persist =
    mkEnableOpt "enables persistence for the home dir";

  # if you have impersistence on, then you probably really dont
  # want to disable this

  # NOTE: when you change something here, remember to remove the
  #  file in /persist/system/home/$user/ since it will just link it if it
  #  exists.
  #  So if you have /persist/system/home/$user/a and persist the file "a"
  #  then ~/a will still be linked to the dir in /persist/$user/a
  config = mkIf cfg.enable {
    home.persistence."/persist/system/home/${config.home.username}" = {
      directories = [
        # force organisation by only persisting ~/persist
        {
          directory = "persist";
          method = "symlink";
          # method = "bindfs";
        }

        ".gnupg"

        ".nixops"
        ".local/share/keyrings" # stores passwords (keys)
        ".local/share/direnv"

        # save discord login
        ".config/discordcanary/Local Storage"

        # save vesktop login
        ".config/vesktop/sessionData/Local Storage"

        # save sops keys
        ".config/sops"

        # save nushell command history
        # ".config/nushell/history.txt"

        ".mozilla/firefox"

        # used to save "initial run" config
        ".config/BraveSoftware/Brave-Browser/"
        ".config/google-chrome/"

        ".local/share/Steam"

        ".local/share/zoxide" # zoxide history

        # ghidra stores state in here
        # its actually in a sub folder based on its version
        # but it too anoying to target that
        # ".config/ghidra"

        # anki stuff
        ".local/share/Anki2"

        # podman images
        ".local/share/containers/storage"
        /*
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
        */
        # lutris
        # "Games/Lutris"
        # "config/lutris"
        ".local/share/lutris"

        # save spotify login
        ".config/spotify"

        # spotify downloaded stuff
        ".cache/spotify/Storage" # "encrypted"
        ".cache/spotify/Users" # keys in here # keys in here

        ".nuget"

        ".config/obsidian"

        ".config/unity3d"

        # technically only this file is needed
        # however bitwarden overrides the symlink
        # ".config/Bitwarden/data.json"
        ".config/Bitwarden"
      ];
      files = [
        # save zsh command history
        ".zsh/history"

        # persist gh (cli) logins
        ".config/gh/hosts.yml"

        ".config/nushell/history.txt"

        ".ssh/known_hosts"
        ".screenrc"
        # ".zsh_history"  # zsh command history
      ];
      allowOther = true;
    };
  };
}
