# auto importer
{self, ...}: {
  perSystem = {
    pkgs,
    inputs',
    lib,
    ...
  }: {
    packages = let
      # currently broken
      ignore = [
        "problem-tools"
        # broken and unused
        "tuxedo-drivers"
        "tuxedo-keyboard"
      ];

      inherit (builtins) readDir;

      autoImported =
        lib.mapAttrs
        (
          k: _:
            pkgs.callPackage ./${k} {}
        )
        (
          lib.filterAttrs
          (
            k: v:
              v
              == "directory"
              && ! builtins.elem k ignore
          )
          (readDir ./.)
        );
    in
      autoImported
      // {
        vesktop = inputs'.nixpkgs-stable.legacyPackages.callPackage ./vesktop {};

        mnw = self.nixosConfigurations.upinix-pc.config.home-manager.users.upidapi.programs.mnw.finalPackage;
      };
  };
}
