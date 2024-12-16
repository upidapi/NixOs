{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit
    (builtins)
    isBool
    isInt
    isString
    isList
    isAttrs
    ;

  inherit
    (lib)
    mkIf
    generators
    strings
    filterAttrs
    mapAttrsToList
    concatStringsSep
    concatMap
    ;

  cfg = config.modules.home.desktop.addons.rofi;
  mkValueString = value:
    if isBool value
    then
      if value
      then "true"
      else "false"
    else if isInt value
    then toString value
    else if (value._type or "") == "literal"
    then value.value
    else if isString value
    then ''"${value}"''
    else if isList value
    then "[ ${strings.concatStringsSep "," (map mkValueString value)} ]"
    else abort "Unhandled value type ${builtins.typeOf value}";

  mkKeyValue = {
    sep ? ": ",
    end ? ";",
  }: name: value: "${name}${sep}${mkValueString value}${end}";

  mkRasiSection = name: value:
    if isAttrs value
    then let
      toRasiKeyValue = generators.toKeyValue {mkKeyValue = mkKeyValue {};};
      # Remove null values so the resulting config does not have empty lines
      configStr = toRasiKeyValue (filterAttrs (_: v: v != null) value);
    in ''
      ${name} {
      ${configStr}}
    ''
    else
      (mkKeyValue {
          sep = " ";
          end = "";
        }
        name
        value)
      + "\n";

  toRasi = attrs:
    concatStringsSep "\n" (concatMap (mapAttrsToList mkRasiSection) [
      (filterAttrs (n: _: n == "@theme") attrs)
      (filterAttrs (n: _: n == "@import") attrs)
      (removeAttrs attrs ["@theme" "@import"])
    ]);

  inherit (config.lib.formats.rasi) mkLiteral;
  mkRgba = opacity: color: let
    c = config.lib.stylix.colors;
    r = c."${color}-rgb-r";
    g = c."${color}-rgb-g";
    b = c."${color}-rgb-b";
  in
    mkLiteral
    "rgba ( ${r}, ${g}, ${b}, ${opacity} % )";
  mkRgb = mkRgba "100";
  rofiOpacity = builtins.toString (builtins.ceil (config.stylix.opacity.popups * 100));
in {
  options.modules.home.desktop.addons.rofi =
    mkEnableOpt "enables rofi, a application runner";

  config = mkIf cfg.enable {
    stylix.targets.rofi.enable = false;

    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      configPath = "${config.xdg.configHome}/rofi/dummy.rasi";
    };

    home.file = {
      ".config/rofi/config.rasi".text = let
        colors = config.lib.stylix.colors.withHashtag;
        colorCfg = toRasi {
          "*" = {
            "background" = mkRgb "base01";
            "background-alt" = mkRgb "base02";
            "foreground" = mkRgb "base07";
            "selected" = mkRgb "base0D";
            "active" = "#FF00FFFF"; # add when needed
            "urgent" = "#FF00FFFF";
          };
        };
        styleImport = toRasi {
          "@import" = "style.rasi";
        };
      in
        colorCfg + styleImport;

      ".config/rofi/style.rasi".source = ./style.rasi;
    };
  };
}
