{
  config,
  lib,
  mlib,
  const,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.media.jfa-go;
  jcfg = config.services.jfa-go;
in {
  options.modules.nixos.homelab.media.jfa-go = mkEnableOpt "";

  imports = [./base.nix];

  config = mkIf cfg.enable {
    sops.templates."jfa-go-cfg" = {
      owner = jcfg.user;
      content = jcfg.cfgFileContent;
    };

    services.jfa-go = {
      enable = true;
      cfgFile = config.sops.templates."jfa-go-cfg".path;
      settings = {
        first_run = false;
        updates = {
          enabled = false;
          channel = "stable";
        };
        jellyfin = {
          username = "admin";
          password = config.sops.placeholder."jellyfin/users/admin/password";
          server = "https://jellyfin.upidapi.dev";
          public_server = "";
          substitute_jellyfin_strings = "Jellyfin";
        };
        ui = {
          port = ports.jfa-go;
          jfa_url = "https://invite.upidapi.dev";
        };
        password_validation = {
          lower = 1;
        };
        jellyseerr = {
          import_existing = false;
        };
        backups = {
          enable = false;
          path = "${jcfg.dataDir}/backup";
        };
        password_resets = {
          watch_directory = "/var/lib/jellyfin";
        };
      };
      apiSettings = {
        "emails/PostSignupCard".content = ''
          <style>
            ${builtins.readFile ./style.css}
          </style>
                
          # Welcome to Jellyfin!
                
          <i>**Note:** You can also see this page on your [acccount page]({myAccountURL})</i>

          ${builtins.readFile ./content.md}
        '';

        "emails/UserPage".content = ''
          <style>
            ${builtins.readFile ./style.css}
          </style>
                
          # Welcome to Jellyfin!
          ${builtins.readFile ./content.md}
        '';
      };
    };
  };
}
