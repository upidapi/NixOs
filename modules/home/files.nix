{
  config,
  lib,
  ...
}: let
  inherit
    (builtins)
    concatStringsSep
    attrValues
    ;

  inherit
    (lib)
    attrNames
    filterAttrs
    foldAttrs
    mapAttrsToList
    hasPrefix
    hm
    literalExpression
    mkDefault
    mkOption
    removePrefix
    types
    escapeShellArg
    ;

  cfg = config.modules.home.standAloneFile;

  homeDirectory = config.home.homeDirectory;
in {
  options.modules.home.standAloneFile = mkOption {
    description = "standalone files to be created";
    default = {};

    type = types.attrsOf (types.submodule
      ({
        name,
        config,
        ...
      }: {
        options = {
          enable = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether this file should be generated. This option allows specific
              files to be disabled.
            '';
          };
          target = mkOption {
            type = types.str;
            apply = p: let
              absPath =
                if hasPrefix "/" p
                then p
                else "${homeDirectory}/${p}";
            in
              removePrefix (homeDirectory + "/") absPath;
            defaultText = literalExpression "name";
            description = ''
              Path to target file relative to ~.
            '';
          };

          text = mkOption {
            # default = "";
            type = types.lines;
            description = ''
              Text of the file
            '';
          };
        };

        config = {
          target = mkDefault name;
        };
      }));
  };

  config = {
    assertions = [
      (
        let
          dups =
            attrNames
            (filterAttrs (n: v: v > 1)
              (foldAttrs (acc: v: acc + v) 0
                (mapAttrsToList (n: v: {${v.target} = 1;}) cfg)));
          dupsStr = concatStringsSep ", " dups;
        in {
          assertion = dups == [];
          message = ''
            Conflicting managed target files: ${dupsStr}

            This may happen, for example, if you have a configuration similar to

                home.file = {
                  conflict1 = { source = ./foo.nix; target = "baz"; };
                  conflict2 = { source = ./bar.nix; target = "baz"; };
                }'';
        }
      )
    ];

    # this will always override the file
    home.activation = {
      createStandAloneFiles =
        lib.hm.dag.entryAfter ["linkGeneration"]
        (concatStringsSep ";" (map (f:
          if !f.enable
          then ""
          else ''echo "${f.text}" > "${f.target}"'')
        (attrValues cfg)));
    };
  };
}
