{
  # systems = ["x86_64-linux"];

  perSystem = {pkgs, ...}: {
    packages = {
      dev-shell = pkgs.callPackage ./dev-shell {};
      qs = pkgs.callPackage ./qs {};
      tuxedo-keyboard = pkgs.callPackage ./tuxedo-keyboard {};
    };
  };
}
