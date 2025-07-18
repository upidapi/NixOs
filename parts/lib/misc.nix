{lib, ...}: let
  inherit (lib) toHexString;
  inherit (builtins) genList concatStringsSep map stringLength;
in rec {
  rPadString = pad: tot: str:
    concatStringsSep "" (
      [str]
      ++ (
        genList
        (_: pad)
        (stringLength str)
      )
    );

  lPadString = pad: tot: str:
    concatStringsSep "" (
      (
        genList
        (_: pad)
        (stringLength str)
      )
      ++ [str]
    );

  mapStylixColors = config: sep: f: let
    inherit (config.lib.stylix) colors;

    color_ids = genList (n: lPadString "0" 2 (toHexString n)) 16;
  in
    concatStringsSep sep (
      map
      (color_id: let
        color_name = "base${color_id}";
        color = colors."${color_name}";
      in
        f color color_name)
      color_ids
    );

  # FROM: https://github.com/diogotcorreia/dotfiles/blob/5e83bc9e7b0c4ac639174332e0cbac3ad1a0d11e/lib/paths.nix#L4
  toPrivateStateDirectory = path: "/var/lib/private/${lib.removePrefix "/var/lib/" path}";
}
