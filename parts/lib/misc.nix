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
}
