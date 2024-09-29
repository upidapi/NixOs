/*
# auto importer
{
  perSystem = {pkgs, inputs', lib, ...}: {
    packages = let
      inherit (builtins) readDir;
    in lib.mapAttrs
        (k: _:
          pkgs.callPackage ./${k} {}
        )
        (lib.filterAttrs
          (_: v: v == "directory")
          (readDir ./.)
        )
      ;
  };
}
*/
{
  perSystem = {pkgs, ...}: {
    packages = {
      dev-shell = pkgs.callPackage ./dev-shell {};
      qs = pkgs.callPackage ./qs {};
      # tuxedo-drivers = pkgs.callPackage ./tuxedo-drivers {};
      problem-tools = pkgs.callPackage ./problem-tools {};
      prelockd = pkgs.callPackage ./prelockd {};
    };
  };
}
