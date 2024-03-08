{...}:
  rec {
    nixpkgs = import <nixpkgs> {};
    inherit (builtins) readDir baseNameOf match mapAttrs;
    inherit (nixpkgs.lib) filterAttrs;

    is-file-kind = kind: kind == "regular";
    is-symlink-kind = kind: kind == "symlink";
    is-directory-kind = kind: kind == "directory";
    is-unknown-kind = kind: kind == "unknown";

    is-nix-file = name: kind: if is-file-kind kind then nixpkgs.lib.hasSuffix ".nix" name else false;

    get-rec-nix-file-struct = path:
      filterAttrs
        (name: contens: contens != null)
        (mapAttrs
          (name: kind:
            if is-directory-kind kind
            then get-rec-nix-file-struct "${path}/${name}"

            else if is-nix-file (name kind)
              then "${path}/${name}"
              else null)
          (readDir path)
        );

    /* module-data formatt:
    mod_data: {
      config = *the mod config*
      options = "the mod options"
      sub_modules = [mod_data]
    }
    */

    only-config = modules_data: {
      inherit (modules_data.config);
      inherit (
        builtins.mapAttrs (
          (_: sub_module_data:
            only-config sub_module_data
          )
        )
      );
    };

    formatt-module-data = data:
      if (data.is_module or false)
        then if data ? options
          then if options == {}
            then "module has no options"
            else {
              options = data.options;
              config = data.config or {};
              sub_modules = {};
            }
          else "module missing options attribute"
        else null;

    get-specific-module-data = module_data: module_path:
      builtins.foldl'
        (sub_module_data: sub_module_path:
          sub_module_data.sub_modules."${module_sub-path}"
            or builtins.throw
              "sub path: ${module_sub_path} not found, full path: ${module_path}"
        )
        config
        module_path;

    eval-module-file = module-data: module-path:
      let
        module-data = formatt-module-data (
          (import module) {
            inherit (only-config module-data);
            mod_config =
              get-specific-module-data.config module-data module-path;
          }
        );
      in if builtins.typeOf module-data == "string"
        then builtins.throw "\"${module-data}\" at ${module-path}"
        else module-data;

    # evals a module-dir part of the nix-file struct
    # eval-module-dir = name: module: module_path:


    eval-module-struct = nix_file_struct: modules_data: module_path:
      filterAttrs
        # non module files are set to null
        (name: contens: contens != null)
        rec {
          modules_data = builtins.mapAttrs (
            (part_name: part:
              if builtins.typeOf (part) == "string"
                then eval-module-file (modules_data) (module_path)
                else
                  let
                    sub_module_data = eval-module-struct (part) (modules_data) (path ++ [name]);
                    default_module = (sub_modules."default.nix" or {});
                  in {
                    sub_modules = builtins.removeAttrs sub_module_data ["default.nix"];
                    # the default.nix file gets added to the modules scope
                    # {some_path}/{name}/default.nix == {some_path}/{name}.nix
                    options = default_module.options or {};
                    config = default_module.config or {};
                  }
            )
            nix_file_struct
          );
        }.modules;

#    get-module-scope-struct = nix_file_struct: part_path:
#      filterAttrs
#        # non module files are set to null
#        (name: contens: contens != null)
}
