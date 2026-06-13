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
  cfg = config.modules.nixos.homelab.media.wizarr;
in {
  options.modules.nixos.homelab.media.wizarr = mkEnableOpt "";

  imports = [./base.nix];

  config = mkIf cfg.enable {
    services.wizarr = {
      enable = true;
      port = ports.wizarr;
    };

    # systemd.tmpfiles.settings = {
    #   "create-wizarr-dir" = {
    #     "/var/lib/wizarr".d = {
    #       group = "wizarr";
    #       user = "wizarr";
    #       mode = "750";
    #     };
    #   };
    # };
    #
    # users.users.wizarr = {
    #   group = "wizarr";
    #   home = "/var/lib/wizarr";
    #   isSystemUser = true;
    # };
    # users.groups.wizarr = {};
    #
    # virtualisation.oci-containers.containers."wizarr" = {
    #   image = "ghcr.io/wizarrrr/wizarr";
    #
    #   # privileged = false;
    #   # user = "${toString config.users.users.wizarr.uid}:${toString config.users.groups.wizarr.gid}";
    #
    #   environment = {
    #     # "DISABLE_BUILTIN_AUTH" = "false";
    #     "PGID" = toString config.users.groups.wizarr.gid;
    #     "PUID" = toString config.users.users.wizarr.uid;
    #     "TZ" = config.time.timeZone;
    #   };
    #   volumes = ["/var/lib/wizarr:/data:rw"];
    #   ports = ["${toString ports.wizarr}:5690/tcp"];
    #   log-driver = "journald";
    #   # extraOptions = ["--network=host"];
    # };
  };
}
