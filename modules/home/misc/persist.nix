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
    home.persistence."/persist/system" = {
      directories = [
        # force organisation by only persisting ~/persist
        {
          directory = "persist";
        }

        ".gnupg"

        ".nixops"
        ".local/share/keyrings" # stores passwords (keys)
        ".local/share/direnv"

        # sops keys, (it seams like this isn't needed)
        ".config/sops"

        ".nuget"

        ".local/share/zoxide" # zoxide history

        # ghidra stores state in here
        # its actually in a sub folder based on its version
        # but it too anoying to target that
        # ".config/ghidra"

        ".local/share/Anki2"

        ".config/obsidian"

        # syncthing state
        ".config/syncthing"

        # podman images
        ".local/share/containers/storage"

        ##############
        # technically only this file is needed
        # .config/Bitwarden/data.json
        # however bitwarden overrides the symlink
        ".config/Bitwarden"

        # discord login
        ".config/discordcanary/Local Storage"

        # vesktop login
        ".config/vesktop/sessionData/Local Storage"

        # save spotify login
        ".config/spotify"

        # spotify downloaded stuff
        ".cache/spotify/Storage" # "encrypted"
        ".cache/spotify/Users" # keys in here # keys in here

        ".config/FreeCAD"
        ".local/share/FreeCAD/" # mods

        ".config/OrcaSlicer"

        ###### games
        ".local/share/PrismLauncher"
        ".local/share/Steam"

        ".local/share/lutris"

        ".config/unity3d"

        # the factory must grow
        ".factorio"

        ".config/Necesse"

        ###### browsers
        ".zen" # why cant they just put it in .config?!

        ".mozilla/firefox"

        # used to save "initial run" config
        ".config/BraveSoftware/Brave-Browser/"
        ".config/google-chrome/"
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
      # allowOther = true;
    };
  };
}
