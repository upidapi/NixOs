{
  perSystem = {
    pkgs,
    # self,
    ...
  }: {
    # formatter = pkgs.alejandra;

    # you can run the installer (run install.sh) with the following command
    # sudo nix --experimental-features "nix-command flakes" run github:upidapi/nixos

    packages = rec {
      default = install;
      # A script that sets up a machine according to a host profile
      install = pkgs.writeShellApplication {
        name = "install";
        runtimeInputs = with pkgs; [git]; # I could make this fancier by adding other deps
        text = ''${./install.sh} "$@"'';
      };
    };

    /*
    apps = rec {
      default = install; # makes the one liner install script slightly shorter;

      # makes it so that you can install one of my systems with a one liner (see readme)
      install = {
        type = "app";
        program = "${self.packages.install}/bin/install";
      };
    };
    */
  };
}
