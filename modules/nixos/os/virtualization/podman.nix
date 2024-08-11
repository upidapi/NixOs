# taken from notashelf
{
  pkgs,
  config,
  my_lib,
  lib,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt enable;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.os.virtualization.podman;
in {
  options.modules.nixos.os.virtualization.podman =
    mkEnableOpt
    "enables the podman for running containers";

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      podman-compose
      podman-desktop
      podman-tui
    ];

    # TODO: virtualisation.containers.enable ?
    #  "Enable common container config files in /etc/container"

    # TODO: only enable if drivers are present?
    # builtins.any (driver: driver == "nvidia") config.services.xserver.videoDrivers;
    hardware.nvidia-container-toolkit = enable;

    virtualisation = {
      # Registries to search for images on `podman pull`
      containers.registries.search = [
        "docker.io"
        "quay.io"
        "ghcr.io"
        "gcr.io"
      ];

      oci-containers.backend = "podman";
      docker.enable = false;

      podman = {
        enable = true;

        # Make Podman backwards compatible with Docker socket interface.
        # Certain interface elements will be different, but unless any
        # of said values are hardcoded, it should not pose a problem
        # for us.
        dockerCompat = true;
        dockerSocket.enable = true;

        defaultNetwork.settings.dns_enabled = true;

        # Prune images and containers periodically
        autoPrune = {
          enable = true;
          flags = ["--all"];
          dates = "weekly";
        };
      };
    };
  };
}
