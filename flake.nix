{
  description = "Nixos config flake";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./parts # parts of the flake
        ./hosts # entry point for all machines / users
      ];

      # required for nixd
      debug = true;

      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/08f22084e6085d19bcfb4be30d1ca76ecb96fe54";
    # works
    # nixpkgs.url = "github:nixos/nixpkgs/ee930f9755f58096ac6e8ca94a1887e0534e2d81";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs-23-05.url = "github:NixOS/nixpkgs/release-23.05";
    # tuxedo-nixos = {
    #   url = "github:sylvesterroos/tuxedo-nixos";
    #
    #   inputs.nixpkgs.follows = "nixpkgs-23-05";
    # };

    vpn-confinement = {
      url = "github:Maroka-chan/VPN-Confinement";
    };

    declarative-jellyfin = {
      # url = "github:upidapi/declarative-jellyfin";
      url = "github:Sveske-Juice/declarative-jellyfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # declarative-arr = {
    #   url = "github:upidapi/declarative-arr";
    #   # url = "/persist/system/home/upidapi/persist/declarative-arr";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    declarr = {
      # url = "/persist/system/home/upidapi/persist/declarr";
      url = "github:upidapi/declarr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-jellyfin = {
      url = "github:upidapi/nixos-jellyfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # got merged into nixpkgs
    # qbit = {
    #   url = "github:undefined-landmark/nixpkgs/default-serverConfig";
    #   # inputs.nixpkgs.follows = "nixpkgs";
    # };

    nix-index-db = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence/home-manager-v2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noshell = {
      url = "github:viperML/noshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1/main";
      # We use the cachix cache provided by hyprland instead
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvirt = {
    #   url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixvirt = {
      url = "github:upidapi/NixVirt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      # IMPORTANT: we're using "libgbm" and is only available in unstable so ensure
      # to have it up-to-date or simply don't specify the nixpkgs input
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mnw.url = "github:Gerg-L/mnw";

    # neovim plugins
    plugin-img-clip = {
      url = "github:HakonHarnes/img-clip.nvim";
      flake = false;
    };
    perfanno-nvim = {
      url = "github:t-troebst/perfanno.nvim";
      flake = false;
    };

    pwndbg = {
      url = "github:pwndbg/pwndbg";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # plugin-neorg-interim-ls = {
    #   url = "github:benlubas/neorg-interim-ls";
    #   flake = false;
    # };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags/v2.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
