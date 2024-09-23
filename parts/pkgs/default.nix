{
  perSystem = {pkgs, ...}: {
    packages = {
      dev-shell = pkgs.callPackage ./dev-shell {};
      qs = pkgs.callPackage ./qs {};
      # TODO: just wait for https://github.com/NixOS/nixpkgs/pull/336633
      # or https://github.com/NixOS/nixpkgs/pull/343483
      # tuxedo-keyboard = pkgs.callPackage ./tuxedo-keyboard {};
      problem-tools = pkgs.callPackage ./problem-tools {};
      prelockd = pkgs.callPackage ./prelockd {};
    };
  };
}
