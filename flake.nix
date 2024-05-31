{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # hyprland.url = "github:hyprwm/Hyprland?rev=9afdd61adeaf413afbe853dbc5fdf6853c8bde21";
    # hyprland.url = "github:hyprwm/Hyprland?rev=3875679755014997776e091ff8903acfb311dd2f";

    # building
    # 37.0 y
    # 34.0 y
    # 32.3 n

    # using
    # unstable n
    # 38.0 n ?
    # 34.0 n
    # 33.0 n
    # stable y

    hyprland.url = "github:hyprwm/Hyprland";
    # hyprland.url = "github:hyprwm/Hyprland?rev=3bb9c7c5cf4f2ee30bf821501499f2308d616f94";
    # "38.0" = "3875679755014997776e091ff8903acfb311dd2f";
    # "32.3" = "9afdd61adeaf413afbe853dbc5fdf6853c8bde21";

    /*
       nur = {
      url = "github:nix-community/NUR";
    };
    */

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of nixvim.
      # url = "github:nix-community/nixvim/nixos-23.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # builtins.readFile ./install.sh

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./hosts
        ./shells
      ];

      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
      perSystem = {
        pkgs,
        self,
        ...
      }: {
        # formatter = pkgs.alejandra;

        packages = {
          # A script that sets up a machine according to a host profile
          install = pkgs.writeShellApplication {
            name = "install";
            runtimeInputs = with pkgs; [git]; # I could make this fancier by adding other deps
            text = ''${./install.sh} "$@"'';
          };
        };

        apps = rec {
          default = install; # makes the one liner install script slightly shorter;

          # makes it so that you can install one of my systems with a one liner (see readme)
          install = {
            type = "app";
            program = "${self.packages.install}/bin/install";
          };
        };
      };
    };
}
