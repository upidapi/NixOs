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

      autoImported = let
        pkgFiles =
          lib.filterAttrs
          (
            k: v:
              v
              == "directory"
              && ! builtins.elem k ignore
          )
          (readDir ./.);
      in
        pkgs.lib.makeScope pkgs.newScope (self: (
          lib.mapAttrs
          (k: _: self.callPackage ./${k} {})
          pkgFiles
        ));
    in
      autoImported
      // {
        vesktop = inputs'.nixpkgs-stable.legacyPackages.callPackage ./vesktop {};

        mnw = self.nixosConfigurations.upinix-pc.config.home-manager.users.upidapi.programs.mnw.finalPackage;
      };
  };
}
