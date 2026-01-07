{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (mlib) mkEnableOpt;
  cfg = config.modules.home.apps.orca-slicer;

  orca-slicer = pkgs.symlinkJoin {
    name = "orca-slicer";
    paths = [pkgs.orca-slicer];
    nativeBuildInputs = [pkgs.makeBinaryWrapper];
    postBuild = ''
      wrapProgram $out/bin/orca-slicer \
        --set __GLX_VENDOR_LIBRARY_NAME mesa \
        --set __EGL_VENDOR_LIBRARY_FILENAMES /run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json \
        --set MESA_LOADER_DRIVER_OVERRIDE zink \
        --set GALLIUM_DRIVER zink \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1
    '';
  };
  # REF: https://github.com/NixOS/nixpkgs/issues/345590
  # orca-slicer = pkgs.orca-slicer.overrideAttrs (old: {
  #   nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
  #
  #   postFixup =
  #     (old.postFixup or "")
  #     + # bash
  #     ''
  #       wrapProgram $out/bin/orca-slicer \
  #         --set __GLX_VENDOR_LIBRARY_NAME mesa \
  #         --set __EGL_VENDOR_LIBRARY_FILENAMES /run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json \
  #         --set MESA_LOADER_DRIVER_OVERRIDE zink \
  #         --set GALLIUM_DRIVER zink \
  #         --set WEBKIT_DISABLE_DMABUF_RENDERER 1
  #     '';
  # });
in {
  options.modules.home.apps.orca-slicer = mkEnableOpt "";

  config = mkIf cfg.enable {
    home.packages = [orca-slicer];
  };
}
