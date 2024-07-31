/*
https://github.com/nix-community/nixvim/blob/main/docs/man/default.nix
https://github.com/nix-community/nixvim/blob/main/docs/default.nix
https://github.com/nix-community/nixdoc
https://github.com/NixOS/nixpkgs/blob/255f5952988a566b0b549d0753e907d6b7d626f3/pkgs/tools/nix/nixos-render-docs/default.nix

{
  config,
  lib,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.misc.docs;

  modules = lib.evalModules {
    modules = [../../pkgs/top-level/config.nix];
    class = "nixpkgsConfig";
  };

  root = toString ../..;

  transformDeclaration = decl: let
    declStr = toString decl;
    subpath = lib.removePrefix "/" (lib.removePrefix root declStr);
  in
    assert lib.hasPrefix root declStr; {
      url = "https://github.com/NixOS/nixpkgs/blob/master/${subpath}";
      name = subpath;
    };

  option-json = nixosOptionsDoc {
    inherit (modules) options;
    documentType = "none";
    transformOptions = opt: opt // {declarations = map transformDeclaration opt.declarations;};
  };
in {
  options.modules.home.misc.docs = mkEnableOpt "enables docs";

  config.home.packages = mkIf cfg.enable [
    (pkgsDoc.callPackage ./man {inherit options-json;})
  ];
}
*/
