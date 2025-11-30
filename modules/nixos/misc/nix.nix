{
  mlib,
  lib,
  config,
  self,
  pkgs,
  inputs,
  ...
}: let
  inherit (mlib) mkOpt;
  inherit (lib) types;
  cfg = config.modules.nixos.nix;
in {
  # used by other modules
  options.modules.nixos.nix = {
    cfg-path =
      mkOpt types.str null
      "that absolute path of the nixos config";

    nh.enable = lib.mkEnableOption "nh, a nix helper";
    gc.enable = lib.mkEnableOption "automatic gc via nh";
    cachix.enable = lib.mkEnableOption "cachix, a nix pkg cache";
    githubToken.enable = lib.mkEnableOption "use of github token for higher rate limits";
    misc.enable = lib.mkEnableOption "a bunch of nix stuff";
  };

  config = lib.mkMerge [
    # nh/gc
    {
      programs.nh = {
        inherit (cfg.nh) enable;
        clean = {
          inherit (cfg.gc) enable;
          extraArgs = "--keep-since 7d --keep 5";
        };
        flake = "/persist/nixos"; # sets NH_OS_FLAKE variable for you
      };
    }

    # cachix
    (lib.mkIf cfg.cachix.enable {
      nix.settings = {
        substituters = [
          # tons of unfree pkgs and other stuff, eg cuda pkgs
          "https://nix-community.cachix.org"
          # "https://cuda-maintainers.cachix.org" # not needed
          "https://cache.nixos.org/"
          "https://hyprland.cachix.org"
          "https://devenv.cachix.org"
          "https://ai.cachix.org"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          # "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
        ];
      };
    })
    # use github token for higher rate limit
    (lib.mkIf cfg.githubToken.enable {
      sops.secrets."github-nix-token" = {
        sopsFile = "${self}/secrets/shared.yaml";
        restartUnits = ["nix-daemon.service"];
      };

      sops.templates."nix-extra-config" = {
        content = ''
          access-tokens = github.com=${config.sops.placeholder."github-nix-token"}
        '';
        mode = "0444";
      };

      # nix.checkConfig = false;
      nix.extraOptions = ''
        !include ${config.sops.templates."nix-extra-config".path}
      '';
    })

    (lib.mkIf cfg.misc.enable {
      environment.sessionVariables = {
        NIXOS_CONFIG_PATH = cfg.cfg-path;
      };

      environment.systemPackages = [
        pkgs.git # for fetching flakes from git repos
      ];

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      nix = let
        flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
      in {
        channel.enable = false;
        /*
        nixPath = [
          # Point to a stable path so system updates immediately update
          "nixpkgs=/run/current-system/nixpkgs"
        ];

        # Pinning flake registry entries, to avoid unpredictable cache invalidation and
        # corresponding large downloads
        registry = {
          nixpkgs.flake = inputs.nixpkgs;
          nixfiles.flake = inputs.self;
        };
        */
        # Opinionated: make flake registry and nix path match flake inputs
        registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
        nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

        settings = {
          # disable global registry
          flake-registry = "";

          auto-optimise-store = true;

          # ALL THE LOGS
          log-lines = 500;
          show-trace = true;

          nix-path = config.nix.nixPath;

          # content addressed derivations
          experimental-features = [
            "ca-derivations"

            # for flakes
            "nix-command"
            "flakes"
          ];
        };
      };
    })
  ];
}
