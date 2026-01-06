{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.freeCad;

  # FROM: https://github.com/x123/dotfiles/blob/eb70885a174e256882ab7f5c59b67e131bd8765b/modules/user/desktop/freecad.nix
  freeCad = pkgs.freecad.overrideAttrs (_: rec {
    # version = "1.1.0-weekly";
    # src = builtins.fetchTarball {
    #   url = "https://github.com/FreeCAD/FreeCAD/tarball/e9f2e8fe92f7015c6ae0d7e3c45f12532f17d744";
    #   sha256 = lib.fakeHash;
    # };

    version = "weekly-2025.12.31";
    src = pkgs.fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      rev = version;
      hash = "sha256-WZp6r38Grl0EXhNx+KBeh/RjwSBlKLQxOUSrV2CiD6c=";
      fetchSubmodules = true;
    };

    # all patches are fixed upstream
    patches = [
      # (pkgs.fetchpatch {
      #   url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/nixpkgs-unstable/pkgs/by-name/fr/freecad/0001-NIXOS-don-t-ignore-PYTHONPATH.patch";
      #   hash = "sha256-PTSowNsb7f981DvZMUzZyREngHh3l8qqrokYO7Q5YtY=";
      # })
      # (pkgs.fetchpatch {
      #   url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/nixpkgs-unstable/pkgs/by-name/fr/freecad/0002-FreeCad-OndselSolver-pkgconfig.patch";
      #   hash = "sha256-3nfidBHoznLgM9J33g7TxRSL2Z2F+++PsR+G476ov7c=";
      # })
      # (pkgs.fetchpatch {
      #   url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/nixpkgs-unstable/pkgs/by-name/fr/freecad/0003-FreeCad-fix-font-load-crash.patch";
      #   hash = "sha256-b00o9Y5kzbEJOKQ9Zo8VXLMY7hv6MPbVfgAYw6V9pdg=";
      # })

      # (pkgs.fetchpatch {
      #   url = "https://github.com/FreeCAD/FreeCAD/commit/8e04c0a3dd9435df0c2dec813b17d02f7b723b19.patch?full_index=1";
      #   hash = "sha256-H6WbJFTY5/IqEdoi5N+7D4A6pVAmZR4D+SqDglwS18c=";
      # })
      # # Inform Coin to use EGL when on Wayland
      # # https://github.com/FreeCAD/FreeCAD/pull/21917
      # (pkgs.fetchpatch {
      #   url = "https://github.com/FreeCAD/FreeCAD/commit/60aa5ff3730d77037ffad0c77ba96b99ef0c7df3.patch?full_index=1";
      #   hash = "sha256-K6PWQ1U+/fsjDuir7MiAKq71CAIHar3nKkO6TKYl32k=";
      # })
    ];
  });

  freecad-weekly = pkgs.freecad.overrideAttrs (_: {
    # version = "1.1.0-weekly";
    # src = builtins.fetchTarball {
    #   url = "https://github.com/FreeCAD/FreeCAD/tarball/e9f2e8fe92f7015c6ae0d7e3c45f12532f17d744";
    #   sha256 = lib.fakeHash;
    # };

    version = "weekly-2025.06.23";
    src = pkgs.fetchFromGitHub {
      owner = "FreeCAD";
      repo = "FreeCAD";
      rev = "weekly-2025.06.23";
      hash = "sha256-1JItuwhZgYCAPKZQ43FKa5BPAXMImPsox+q8snngdxU=";
      fetchSubmodules = true;
    };

    patches = [
      (pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/nixpkgs-unstable/pkgs/by-name/fr/freecad/0001-NIXOS-don-t-ignore-PYTHONPATH.patch";
        hash = "sha256-PTSowNsb7f981DvZMUzZyREngHh3l8qqrokYO7Q5YtY=";
      })
      (pkgs.fetchpatch {
        url = "https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/nixpkgs-unstable/pkgs/by-name/fr/freecad/0002-FreeCad-OndselSolver-pkgconfig.patch";
        hash = "sha256-3nfidBHoznLgM9J33g7TxRSL2Z2F+++PsR+G476ov7c=";
      })
    ];
  });
in {
  options.modules.home.apps.freeCad = mkEnableOpt "";

  config = mkIf cfg.enable {
    home.packages = [freecad-weekly];
  };
}
