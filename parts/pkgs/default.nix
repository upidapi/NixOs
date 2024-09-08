{
  perSystem = {pkgs, ...}: {
    packages = {
      dev-shell = pkgs.callPackage ./dev-shell {};
      qs = pkgs.callPackage ./qs {};
      tuxedo-keyboard = pkgs.callPackage ./tuxedo-keyboard {};
      problem-tools = pkgs.callPackage ./problem-tools {};
      prelockd = pkgs.callPackage ./prelockd {};
    };
  };
}
