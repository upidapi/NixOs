# auto importer
{
  perSystem = {
    pkgs,
    inputs',
    lib,
    ...
  }: {
    packages = let
      # currently broken
      ignore = ["tuxedo-drivers" "tuxedo-keyboard"]; # broken and unused

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
      };
  };
}
