
/*
module syntax:
{
  modules  # referancees to all other modules
  mod_cfg  # referance to this mods own config

  *all normall module args*

  *all exrtra args passed to this module*
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

  rec {
    nixpkgs = import <nixpkgs> {};
    inherit (builtins) readDir baseNameOf match mapAttrs;
    inherit (nixpkgs.lib) filterAttrs;

    recursiveMerge = with nixpkgs.lib; attr_list:
      let f = attr_path:
        zipAttrsWith (n: values:
          if tail values == []
            then head values
          else if all lib.isList values
            then unique (concatLists values)
          else if all isAttrs values
            then f (attr_path ++ [n]) values
          else last values
        );
      in f [] attr_list;

    is-file-kind = kind: kind == "regular";
    is-symlink-kind = kind: kind == "symlink";
    is-directory-kind = kind: kind == "directory";
    is-unknown-kind = kind: kind == "unknown";

    is-nix-file = name: kind: if is-file-kind kind then nixpkgs.lib.hasSuffix ".nix" name else false;
    
    remove-n-chars = string: n:
   	builtins.substring 0 (builtins.stringLength(string) - n) string;

    get-rec-nix-file-struct = path:
      filterAttrs
        (name: contens: contens != null)
	(builtins.listToAttrs 
	  (builtins.attrValues
            (mapAttrs
              (name: kind: 
                if is-directory-kind kind
                then  {
	          name = name;
	          value = get-rec-nix-file-struct "${path}/${name}";
	        }

                else {
	          name = remove-n-chars name 4;
	          value = if (is-nix-file name kind)
                    then "${path}/${name}"
                    else null;
	        }
	      )
              (readDir path)
	    )
          )
	);

    /* module-data formatt:
    mod_data: {
      config = *the mod config*
      options = "the mod options"
      sub_modules = [mod_data]
    }
    */
    only-part = modules_data: thing:
      modules_data."${thing}"
      // (builtins.mapAttrs 
          (_: sub_module_data:
            (only-part sub_module_data thing)
          )
	  modules_data.sub_modules or {}
      );     

    only-config = modules_data: 
      only-part modules_data "config";

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

    eval-module-file = module_data_pos: module-data: module-path:
      let
        module-data = formatt-module-data (
          (import module-path) {
            modules = (only-config module-data);
            mod_cfg =
              get-specific-module-data.config module-data module_data_pos;
          }
        );
      in if builtins.typeOf module-data == "string"
        then builtins.throw "\"${module-data}\" at ${module-path}"
        else module-data;

   eval-module-struct = {nix_file_struct, modules_data_inp, module_data_pos}:
        # non module files are set to null
        rec {
          modules_data = (
	    if (builtins.typeOf nix_file_struct) == "string"
              then eval-module-file 
	        (module_data_pos)  # where the data for the module is stored
		(recursiveMerge [modules_data modules_data_inp])  # all data 
		(nix_file_struct)  # path of module
	      else let
                sub_module_data = filterAttrs
        	  (name: contens: contens != null)
		  (builtins.mapAttrs
                    (part_name: part:
	              eval-module-struct {
	  	        nix_file_struct = part;
		        modules_data_inp = recursiveMerge [modules_data modules_data_inp];
		        module_data_pos = module_data_pos ++ [part_name];
		      }
		    )
	            nix_file_struct
		  );

                default_module = (sub_module_data."default" or {});
 	      in {
                sub_modules = builtins.removeAttrs sub_module_data ["default"];
                # the default.nix file gets added to the modules scope
                # {some_path}/{name}/default.nix == {some_path}/{name}.nix
                options = default_module.options or {};
                config = default_module.config or {};
              }
	  );
	}.modules_data;
    
    # All kwargs passes to eval-module-tree are passed onto
    # all sub-modules.
    eval-module-tree = mod_loader_cfg: 
      {config, options, pkgs, modulesPath}@mod_inp:

      let
        modules = rec {
          nix_file_struct = get-rec-nix-file-struct nix_file_root;
  	  modules = (eval-module-struct 
	    nix_file_struct 
	    config # modules // 
	    ["modules"]
	  );
        }.modules;
      in {  # this is the resulting module scope
        options = only-part modules "options";
        config = only-part modules "config";
      };

    # todo make this into an importable module:

    # this iw was is given to modules
    # [ "config" "inputs" "lib" "modulesPath" "options" "specialArgs" ]
  }.eval-module-tree;

/*
how to use this:

1. add the folowing to your flakes modules:
import *path to this* {src = *entry point for your modules*}

2. profit

3. more nix pain
*/

# todo move this to a better place
