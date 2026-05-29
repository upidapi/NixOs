{
  config,
  lib,
  mlib,
  const,
  self,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  inherit (const) ports;
  cfg = config.modules.nixos.homelab.services.shlink;
in {
  options.modules.nixos.homelab.services.shlink = mkEnableOpt "";

  imports = [
    # inputs.camasca.nixosModules.shlink
  ];

  # podman exec -it shlink shlink api-key:list

  # https://github.com/dubinc/dub is prob good
  #  but a pain in the ass to self host
  #  requires like 100 things
  config = mkIf cfg.enable {
    sops.secrets."shlink/api-key" = {
      # owner = "podman";
      sopsFile = "${self}/secrets/server.yaml";
    };
    sops.templates."shlink-env" = {
      content = ''
        INITIAL_API_KEY=${config.sops.placeholder."shlink/api-key"}
      '';
    };

    # environment.systemPackages = [config.services.shlink.package];

    virtualisation.oci-containers.containers."shlink" = {
      image = "shlinkio/shlink:stable";
      # ports = ["127.0.0.1:8385:${toString ports.shlink}"];
      # environment = {
      #   # PORT = toString ports.shlink;
      #   DEFAULT_DOMAIN = "l.upidapi.dev";
      #   IS_HTTPS_ENABLED = "true";
      #   DB_DRIVER = "postgres";
      #   DB_UNIX_SOCKET = "/var/run/postgresql";
      #   DB_USER = "shlink";
      #
      #   # PORT = "8385";
      #   #
      #   # DB_DRIVER = "postgres";
      #   # DB_HOST = "host.docker.internal";
      #   # DB_PORT = "5432";
      #   # DB_NAME = "shlink";
      #   # DB_USER = "shlink";
      #   # DB_PASSWORD = "shlink";
      #
      #
      # };

      # extraOptions = ["--add-host=host.docker.internal:host-gateway"];
      # Use "host.containers.internal" if backend is Podman
      # DB_HOST = "host.docker.internal";

      environmentFiles = [
        config.sops.templates.shlink-env.path
      ];

      extraOptions = ["--network=host"];

      environment = {
        DEFAULT_DOMAIN = "l.upidapi.dev";
        IS_HTTPS_ENABLED = "true";
        PORT = toString ports.shlink;

        DB_DRIVER = "postgres";
        DB_HOST = "127.0.0.1";
        DB_PORT = toString ports.pg;
        DB_NAME = "shlink";
        DB_USER = "shlink";
        SHELL_VERBOSITY = "3";

        INITIAL_API_KEY_FILE = config.sops.secrets."shlink/api-key".path;
      };
    };
    virtualisation.oci-containers.containers."shlink-web" = {
      image = "shlinkio/shlink-web-client";
      ports = ["127.0.0.1:${toString ports.shlink-web}:8080"];

      # environment = {
      #   PORT = toString ports.shlink-web;
      # };
    };

    services = {
      # shlink = {
      #   enable = true;
      #   environment = {
      #     PORT = toString ports.shlink;
      #     DEFAULT_DOMAIN = "link.upidapi.dev";
      #     IS_HTTPS_ENABLED = "true";
      #     DB_DRIVER = "postgres";
      #     DB_UNIX_SOCKET = "/var/run/postgresql";
      #   };
      # };
      postgresql = {
        ensureDatabases = ["shlink"];
        ensureUsers = [
          {
            name = "shlink";
            ensureDBOwnership = true;
          }
        ];
      };

      caddy.virtualHosts = {
        # "upidapi.dev".extraConfig = ''
        # '';
        "l.upidapi.dev".extraConfig = ''
          import harden_headers

          reverse_proxy :${toString ports.shlink}
        '';

        "link.upidapi.dev".extraConfig = ''
          import harden_headers

          reverse_proxy :${toString ports.shlink-web}
        '';
      };
    };
  };
}
