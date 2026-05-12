# TODO: config the .xml network file, take from declaratove jellyfin
{
  config,
  lib,
  mlib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf attrsets strings;
  inherit (mlib) mkEnableOpt;
  cfg = config.services.jellarr;

  toXMLGeneric = let
    toXMLRecursive = toXmlRecursive' "<?xml version='1.0' encoding='utf-8'?>\n" 0;

    indent = depth: (
      if (depth <= 0)
      then ""
      else ("  " + (indent (depth - 1)))
    );

    toXmlRecursive' = str: depth: xml: let
      parseTag = str: depth: xml: (builtins.concatStringsSep "" [
        str
        "${indent depth}<${xml.tag}${
          if (builtins.hasAttr "attrib" xml)
          then " ${builtins.concatStringsSep " " (
            attrsets.mapAttrsToList (name: value: "${name}=\"${strings.escapeXML value}\"") xml.attrib
          )}"
          else ""
        }${
          if
            !(builtins.hasAttr "content" xml)
            || ((builtins.isString xml.content) && xml.content == "")
            || ((builtins.isList xml.content) && xml.content == [])
          then " />"
          else ">${(toXmlRecursive' "\n" (depth + 1) xml.content)}</${xml.tag}>"
        }"
      ]);
    in
      if (builtins.isAttrs xml)
      then "${parseTag str depth xml}\n${indent (depth - 1)}"
      else if (builtins.isList xml)
      then "\n${
        (builtins.concatStringsSep "" (map (x: (toXmlRecursive' "" depth x)) xml))
      }${indent (depth - 1)}"
      else if ((builtins.isInt xml) || (xml == null) || (builtins.isFloat xml))
      then (toString xml)
      else if (builtins.isString xml)
      then pkgs.lib.strings.escapeXML xml
      else if (builtins.isBool xml)
      then
        if xml
        then "true"
        else "false"
      else throw "Cannot convert a ${builtins.typeOf xml} to XML. ${toString (builtins.trace xml xml)}";
  in
    toXMLRecursive;
  toPascalCase = let
    toPascalCase = parts:
      builtins.foldl' (a: b: a + b) "" (
        map (
          part: let
            firstChar = builtins.substring 0 1 part;
            rest = builtins.substring 1 ((builtins.stringLength part) - 1) part;
          in
            # If part is entirely lowercase, capitalize first letter
            # Otherwise, preserve the part's original casing
            if part == lib.strings.toLower part
            then "${lib.strings.toUpper firstChar}${rest}"
            else part
        )
        parts
      );
  in rec {
    fromString = x:
      toPascalCase (
        builtins.concatLists (
          builtins.filter builtins.isList (builtins.split "([[:upper:]]+[[:lower:]]+|[[:upper:]]|[[:lower:]]+|[[:digit:]]+)" x)
        )
      );
    # Recursively renames attributes to PascalCase
    fromAttrs' = f: x:
      if builtins.isAttrs x
      then
        lib.attrsets.mapAttrs' (
          name: value: let
            isReserved = lib.elem name [
              "tag"
              "content"
              "attrib"
            ];
            newName =
              if isReserved
              then name
              else fromString name;
          in
            lib.attrsets.nameValuePair newName (f value)
        )
        x
      else if builtins.isList x
      then map f x
      else x;
    fromAttrs = fromAttrs' (x: x);
    fromAttrsRecursive = fromAttrs' fromAttrsRecursive;
  };

  isStrList = x: lib.all lib.isString x;

  prepass = x:
    if (lib.isAttrs x)
    then
      if !(lib.hasAttr "tag" x)
      then
        attrsets.mapAttrsToList (tag: value: {
          inherit tag;
          content = prepass value;
        })
        x
      else if (lib.hasAttr "content" x)
      then {
        inherit (x) tag;
        content = prepass x.content;
      }
      else x
    else if (lib.isList x)
    then
      if (isStrList x)
      then
        (map (content: {
            tag = "string";
            inherit content;
          })
          x)
      else map prepass x
    else x;

  toXml = tag: x: (toXMLGeneric {
    inherit tag;
    attrib = {
      "xmlns:xsi" = "http://www.w3.org/2001/XMLSchema-instance";
      "xmlns:xsd" = "http://www.w3.org/2001/XMLSchema";
    };
    content = prepass x;
  });
  jellyfinConfigFiles = {
    "network.xml" = {
      name = "NetworkConfiguration";
      content = toPascalCase.fromAttrsRecursive cfg.network;
    };
    "encoding.xml" = {
      name = "EncodingOptions";
      content = toPascalCase.fromAttrsRecursive cfg.encoding;
    };
    "system.xml" = {
      name = "ServerConfiguration";
      content = toPascalCase.fromAttrsRecursive cfg.system;
    };
    "branding.xml" = {
      name = "BrandingOptions";
      content = toPascalCase.fromAttrsRecursive cfg.branding;
    };
  };
in {
  imports = [
    ./branding.nix
    ./encoding.nix
    ./network.nix
    ./system.nix
  ];

  options.modules.services.jellarr = {
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."jellyfin-cfg-create" =
      lib.mapAttrs'
      (
        k: v: {
          name = "${cfg.bootstrap.jellyfinDataDir}/config/${k}";
          value.f = {
            inherit (cfg) user group;
            mode = "640";
            argument = toXml v.name v.content;
          };
        }
      )
      jellyfinConfigFiles;
  };
}
