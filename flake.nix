{
  description = "Nixos config flake";
  
  # install hm on nix-portable
  # https://github.com/nix-community/home-manager/issues/3752#issuecomment-1566179742
  # you have to use "https://hydra.nixos.org/job/nix/master/buildStatic.x86_64-linux/latest"
  # the click on download
  # TODO: find a perma direct link 

  /* -------OLD--------
  ## setup nix 
  mkdir -p ~/.config/nix
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  mkdir -p ~/.local/bin  
  
  # TODO: not correct link (see above)
  curl https://hydra.nixos.org/build/262696224/download/2/nix -o ~/.local/bin/nix

  # curl -o ~/.local/bin/nix -L https://hydra.nixos.org/job/nix/master/buildStatic.x86_64-linux/latest/download/1
  chmod +x ~/.local/bin/nix
  export PATH=~/.local/bin:$PATH


  ## build activation pkg
  nix shell nixpkgs#nix --command bash --noprofile --norc -l

  # name in the hm conf must be same as user
  nix build .#homeConfigurations.drs_temp_mk2416.activationPackage
  

  ## exit and start zsh
  exit
  nix run nixpkgs#zsh
  */

  /* --------NEW-------
  # set -ex

  ## get nix portable
  # export PATH=$PATH:$HOME/.local/bin
  # mkdir -p .local/bin
  # cd .local/bin

  # Download nix-portable
  curl -L "https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m)" > ./nix-portable

  # Generate symlinks for seamless integration
  chmod +x nix-portable
  ln -s nix-portable nix
  
  cd ~
  ./nix-portable nix-shell -p home-manager nix zsh  
  home-manager switch -b old --flake github:upidapi/NixOs#drs_temp_mk2416
  zsh

  alias nvim="zsh $(which nvim)"
  alias man="zsh $(which man)"
  # alias nvim="zsh $(which nvim)"

  # for some reason yo have to use "zsh $(which --cmd--)" to run a command that uses exec
  # since running scripts with exec breaks bash
  # nvim
  */

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./parts # parts of the flake
        ./hosts # entry point for all machines / users

        # TODO: move this to eg home/default.nix or lib/mk_homes.nix
        ({
          inputs,
          self,
          withSystem,
          lib,
          ...
        }: {
          flake.homeConfigurations = {
            # "${name}" = withSystem system (
            "drs_temp_mk2416" = withSystem "x86_64-linux" (
              {
                pkgs,
                inputs',
                self',
                ...
              }: 
              let
                extra_args = {
                  inherit inputs inputs' self self';

                  # TODO: try to put thease in /parts
                  my_lib = (import ./parts/lib) {inherit lib;};
                  keys = (import ./parts/keys.nix) {inherit lib;}; 
                  osConfig = {
                    modules.nixos = {
                      nix.cfg-path = "~/persist/NixOs";
                      hardware.monitors = [];
                    };
                  };
                };

                user-name = "drs_temp_mk2416";
                enable = {enable = true;};
                system = "x86_64-linux";
              in
              inputs.home-manager.lib.homeManagerConfiguration {
                inherit pkgs;
                
                modules = [ 
                  # inputs.hyprland.homeManagerModules.default

                  {
                    home.username = user-name;

                    # only for testing
                    # home.stateVersion = "23.11";

                    home.homeDirectory = "/mnt/${user-name}";
                  }

                  
                  ./modules/home

                  
                  # "${host_dir}/${profile}/users/${user-name}.nix" 
                  { 
		    home.sessionVariables.PATH = "$HOME/.nix-profile/bin:$PATH";
		    
                    nixpkgs.config.allowUnfreePredicate = pkg:
                      builtins.elem (pkgs.lib.getName pkg) [
                        "spotify"
                        # "steam"
                        # "steam-run"
                        # "steam-original"
                      ];

                    home.stateVersion = "23.11"; # Read comment

		    {
		      fonts.fontconfig.enable = true;
		      home.packages = [
			(pkgs.nerdfonts.override {fonts = ["NerdFontsSymbolsOnly"];})
		      ];
		    }

                    modules.home = {
                      other = enable;

                      apps = {
                        alacritty = enable;
                        bitwarden = enable;
                        discord = enable;
                        firefox = enable;
                        r2modman = enable;
                        spotify = enable;
                      };

                      cli-apps = {
                        nixvim = enable;
                        # nushell = enable;
                        tmux = enable;
                        zsh = {
                          enable = true;
                          set-shell = true;
                        };
                        wine = enable;
                        git = enable;
                        bat = enable;
                        cn-bth = enable;
                      };

                      services = {
                        playerctl = enable;
                      };

                      misc = {
                        dconf = enable;
                        sops = enable;
                        # persist = enable;
                      };

                      desktop = {
                        wayland = enable;
                        hyprland = enable;
                        addons = {
                          swww = enable;
                          # eww = enable;
                          ags = enable;
                          dunst = enable;
                          gtk = enable;
                          rofi = enable;
                          waybar = enable;
                        };
                      };
                    };
                  }
                  
                ];
                extraSpecialArgs = extra_args;
                
              });
          };
        })

      ];

      systems = [
        # systems for which you want to build the `perSystem` attributes
        "x86_64-linux"
        # ...
      ];
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    flake-parts.url = "github:hercules-ci/flake-parts";

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

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
  };
}
