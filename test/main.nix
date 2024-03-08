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

            else if (is-nix-file name kind)
              then "${path}/${name}"
              else null)
          (readDir path)
       );

    # get-rec-nix-file-struct = path: (mapAttrs (name: kind: name) (readDir path));

    /* module-data formatt:
    mod_data: {
      config = *the mod config*
      options = "the mod options"
      sub_modules = [mod_data]
    }

    module syntax:
    {
      modules  # referancees to all other modules
      mod_cfg  # referance to this mods own config 
    }: {
      # signals that this is a module
      is-modules = true;

      options = {
        *the options that other modules and things can set*
      };

      conifg = {
        *options this modules sets*
      };
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
          then if data.options == {}
            then "module has no options"
            else {
              options = data.options;
              config = data.config or {};
              sub_modules = {};
            }
          else "module missing options attribute"
        else null;  # (builtins.trace (builtins.toJSON data) null);

    get-specific-module-data = module_data: module_path:
      builtins.foldl'
        (sub_module_data: sub_module_path:
          sub_module_data.sub_modules."${sub_module_data}"
            or builtins.throw
              "sub path: ${sub_module_path} not found, full path: ${module_path}"
        )
	module_data
        module_path;

    eval-module-file = module-data: module-path:
      let
        module-data = formatt-module-data (
          (import module-path) {
            modules = (only-config module-data);
            mod_cfg =
              get-specific-module-data.config module-data module-path;
          }
        );
      in if builtins.typeOf module-data == "string"
        then builtins.throw "\"${module-data}\" at ${module-path}"
        else module-data;

    # evals a module-dir part of the nix-file struct
    # eval-module-dir = name: module: module_path:


    eval-module-struct = nix_file_struct: modules_data: module_path:
      /* filterAttrs
        # non module files are set to null
        (name: contens: contens != null) */
        rec {
          modules_data = (builtins.mapAttrs
            (part_name: part:
              if builtins.typeOf (part) == "string"
                then eval-module-file (modules_data) (module_path)
                else
                  let
                    sub_module_data = eval-module-struct 
		      (part) 
		      (modules_data) 
		      (module_path ++ [part_name]);
                    default_module = (sub_module_data.sub_modules."default.nix" or {});
                  in {
                    sub_modules = builtins.removeAttrs sub_module_data ["default.nix"];
                    # the default.nix file gets added to the modules scope
                    # {some_path}/{name}/default.nix == {some_path}/{name}.nix
                    options = default_module.options or {};
                    config = default_module.config or {};
                  }
            )
            nix_file_struct);
        }.modules_data;
   
    /* eval-module-struct = nix_file_struct: modules_data: module_path:
      #  filterAttrs
        # non module files are set to null
       #  (name: contens: contens != null)
        rec {
          modules_data = 
	    if builtins.typeOf (nix_file_struct) == "string"
              then eval-module-file (modules_data) (nix_file_struct)
              else (builtins.mapAttrs
                (part_name: part:
                  let
                    sub_module_data = eval-module-struct 
		      (part) :
		      (modules_data) 
		      (module_path ++ [part_name]);
                    default_module = (sub_module_data.sub_modules."default.nix" or {});
                  in {
                    sub_modules = builtins.removeAttrs sub_module_data ["default.nix"];
                    # the default.nix file gets added to the modules scope
                    # {some_path}/{name}/default.nix == {some_path}/{name}.nix
                    options = default_module.options or {};
                    config = default_module.config or {};
                  }
            )
            nix_file_struct);
        }.modules_data; */

    true-eval = nix_file_root:
      rec {
        nix_file_struct = get-rec-nix-file-struct nix_file_root;
	modules = eval-module-struct nix_file_struct modules nix_file_root;
      }.modules;

#    get-module-scope-struct = nix_file_struct: part_path:
#      filterAttrs
#        # non module files are set to null
#        (name: contens: contens != null)
}/* rec {
  module_paths = {
    a = ./a.nix;
    b = ./b.nix;
  };
  modules = builtins.mapAttrs 
    (_: module:
      (import module) {inherit modules;}
    )
    module_paths;
} */

    # /{project_root}/modules/discord/default.nix
    # or
    # /{project_root}/modules/discord.nix

/* rec {
  inp = 0;
  self = import ./main.nix;
  out = self.inp + 1;
} */
