

# desc 
/*
This thing loads all modules in a directory tree 
into one big master module.

The sub directorys in the tree forces structure since
each module's option scope correspons to where it is
in the tree

Src is the entry point to said tree.
Scope is where all of the opts of the module is placed
    if none then they're added to the same scope as 
    everything else

Through some lazy eval fuckery it basivally puts all
of the actuall sub modules in the same scope. They 
can accsess eachothers config. Whithout you actually 
manually importing the modules one depends on.

2 (or more) modules can therefour reference eachothers
config. Unless it's trully circular. For example 
b = a and a = b. Wouldn't work
*/

# how to use this:
/*
1. add this to the imports wheever you whant to use it
import ./load-modules.nix {
  src = ./modules  # entry point for your modules
}

2. profit

3. more nix pain
*/

# module syntax:
/*
{
  config  # refernace to all config, including all defined in this tree

  mod_cfg  # referance to this mods own config

  *all normall module args*

  *all exrtra args passed to the loader*
}: {
  # signals that this is a module
  is_module = true;

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

  is-file-kind = kind: kind == "regular";
  is-symlink-kind = kind: kind == "symlink";
  is-directory-kind = kind: kind == "directory";
  is-unknown-kind = kind: kind == "unknown";

  should-add = name: kind:  
    (is-file-kind kind) &&
    # (
    #   (nixpkgs.lib.hasPrefix "-" name) ||
    #   (name == "default.nix")
    # ) &&
    (nixpkgs.lib.hasPrefix "-" name) && 
    (nixpkgs.lib.hasSuffix ".nix" name);
  
  slice-str = string: start: stop: 
    let
      end = if stop < 0
        then builtins.stringLength(string) + stop
	else stop;
    in
      builtins.substring start end string;

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
                  name = slice-str name 1 (-4);
                  value = if (should-add name kind)
                    then "${path}/${name}"
                    else null;
                }
            )
            (readDir path)
          )
        )
      );

  recursiveMerge = with nixpkgs.lib; attr_list:
    let f = attr_path:
      zipAttrsWith (n: values:
        if tail values == []
          then head values
        else if all isList values
          then unique (concatLists values)
        else if all isAttrs values
          then f (attr_path ++ [n]) values
        else last values
      );
    in f [] attr_list;

  # todo make the config not get added to the module scope
  # but to the global scope

  /* module-data formatt:
  mod_data: {
    # stuff to add to the module scope
    module = {
      config = *the mod config*
    }
    
    # stuff to add to the global scope
    global = {
      options = "the mod options"
      sub_modules = [mod_data]
    }

  */

  # recursivly gets the attrs of an object
  # rec-get-attr obj ["a", "b", "c"] = obj.a.b.c
  rec-get-attr = object: attr_path:
    builtins.foldl'
      (sub_object: attr:
        sub_object."${attr}"
          or (builtins.throw
            "attr not found: ${attr} not found, full path: ${attr_path}")
      )
      object
      attr_path;

  # gets the specific parts of all modules
  only-part = modules_data: thing: 
    (rec-get-attr modules_data thing)
    // (builtins.mapAttrs
      (_: sub_module_data:
        (only-part sub_module_data thing)
      )
      modules_data.module.sub_modules or {}
    );
  
  # modules higer up in the tree are prioritised
  merge-data = modules_data:
    recursiveMerge ((
      builtins.map
        (x: merge-data x)
        (builtins.attrValues
          modules_data.sub_modules or {}
	)
      ) ++ [ {
        config = modules_data.data.config; 
	options = modules_data.data.options;
      } ]
    );
  
  eval-full = {
    full_struct,
    # extra_args,
    mod_data_formatter,
  }: let  
    eval-file = {
      path,
      mod_pos,
      mod_data
    }: {
      sub_modules = {};
      data = import path ( 
        mod_data_formatter 
	  mod_pos # extra_args
	  mod_data 
      );
    };
    
    # eval-struct = {
    #   mod_struct,
    #   mod_pos,
    #   mod_data_inp
    # }:  
        
    eval-part = {
      mod_struct,
      mod_pos,
      mod_data_inp
    }: 
      rec {
        mod_data = if (builtins.typeOf mod_struct) != "set"
          then eval-file {
  	    path = mod_struct;
  	    mod_pos = mod_pos;
	    mod_data = mod_data;
	  }
	  else 
	    let
	      sub_data = (builtins.mapAttrs 
                (name: sub_struct: eval-part {
                  mod_struct = sub_struct;
	          mod_pos = mod_pos ++ [name];
	          mod_data = recursiveMerge [
	            mod_data 
		    mod_data_inp
	          ];
	        })
		mod_struct
	      );
	    in recursiveMerge [
              (sub_module_data."default" or {data = {};}) 
	      { 
	        sub_modules = 
                  builtins.removeAttrs 
		    sub_module_data 
		    ["default"];
	      }
	    ];
      };

  /* in_scope: mod_pos: scope:
    (nixpkgs.lib.drop 
      (builtins.length scope)
      mod_pos 
    ) == scope; */
  
  /*only-allowed: mod_data: allowed: path: {
    sub_modules = builtins.mapAttrs 
      
      mod_data.sub_modules
  }*/

  # formatt_data = mod_data: mod_pos: 
  # 
  #   if in_scope 
  
  # All kwargs passes to eval-module-tree are passed onto
  # all sub-modules.
  load-modules = mod_loader_cfg:
    {config, options, pkgs, modulesPath}@mod_inp:
      let 
          scope = mod_loader_cfg.scope or null;

	  nix_file_struct = if scope == null 
	    then get-rec-nix-file-struct mod_loader_cfg.src
	    else wrap-thing-with 
	      scope 
	      (get-rec-nix-file-struct 
	        mod_loader_cfg.src
	      );

          modules = merge-data (eval-full {
	    mod_data_formatter = mod_pos: mod_data: 
	      recursiveMerge [
	        mod_inp
                { config = (merge-data mod_data).config; }
	      ];
	    full_struct = nix_file_struct;
	  });
      in {  # this is the resulting module scope
        options = modules.options;
        config = modules.config;
      }; 
}

  # this is what is given to modules by nix's module system (by default)
  # [ "config" "inputs" "lib" "modulesPath" "options" "specialArgs" ]


