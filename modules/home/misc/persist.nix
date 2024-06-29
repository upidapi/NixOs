{
  config,
  my_lib,
  lib,
  inputs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
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
  config = mkIf cfg.enable {
    home.persistence."/persist/home/${config.home.username}" = {
      directories = [
        # force organisation
        # "Downloads"
        # "Music"
        # "Pictures"
        # "Documents"
        # "Videos"

        # "projects"
        "persist"

        # "VirtualBox VMs"
        ".gnupg"

        ".ssh/known_hosts"

        ".nixops"
        ".local/share/keyrings" # stores passwords (keys)
        ".local/share/direnv"

        # save discord login
        ".config/discordcanary/Local Storage"

        # save vesktop login
        ".config/vesktop/sessionData/Local Storage"

        # save zsh command history
        ".zsh/history"

        # persist spotify login
        ".config/spotify"

        # save sops keys
        ".config/sops"

        # save nushell command history
        # ".config/nushell/history.txt"

        # thers probably some better way
        # i should probably make this more specific
        # to only save tabs, bookmarks and enabled extensions
        ".mozilla/firefox"
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
      ];
      files = [
        ".screenrc"
        # ".zsh_history"  # zsh command history
      ];
      allowOther = true;
    };
  };
}
