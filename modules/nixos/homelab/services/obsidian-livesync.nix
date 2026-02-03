{
  config,
  lib,
  mlib,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.nixos.homelab.services.obsidian-livesync;
in {
  options.modules.nixos.homelab.services.obsidian-livesync = mkEnableOpt "";

  config = mkIf cfg.enable {
    # REF: https://github.com/tigorlazuardi/nixos/blob/9d7a8d8cd285356bfc523e6349accba753ba699a/system/services/couchdb.nix#L59
    sops = {
      secrets = {
        "couchdb/admin/username".sopsFile = "${self}/secrets/server.yaml";
        "couchdb/admin/password".sopsFile = "${self}/secrets/server.yaml";
      };

      templates."couchdb.ini" = {
        owner = config.services.couchdb.user;
        content = lib.generators.toINI {
          admins = {
            ${config.sops.placeholder."couchdb/admin/username"} =
              config.sops.placeholder."couchdb/admin/password";
          };
        };
      };
    };

    # FROM: https://github.com/mikeodr/nixos-config/blob/6f72fa31cf57056b97648e76d585cf1a102b3ba4/hosts/luna/obsidian.nix#L21
    services.couchdb = {
      enable = true;
      extraConfigFiles = [config.sops.templates."couchdb.ini"];

      # https://github.com/vrtmrz/obsidian-livesync/blob/main/docs/setup_own_server.md#configure
      extraConfig = {
        couchdb = {
          single_node = true;
          max_document_size = 50000000;
        };

        chttpd = {
          require_valid_user = true;
          # random ahhh number
          max_http_request_size = 4294967296;
          enable_cors = true;
        };

        chttpd_auth = {
          require_valid_user = true;
          authentication_redirect = "/_utils/session.html";
        };

        httpd = {
          WWW-Authenticate = ''Basic realm = "couchdb"'';

          enable_cors = true;
        };

        cors = {
          origins = "app://obsidian.md, capacitor://localhost, http://localhost";
          credentials = true;
          headers = "accept, authorization, content-type, origin, referer";
          methods = "GET,PUT,POST,HEAD,DELETE";
          max_age = 3600;
        };
      };
    };
  };
}
