

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

  options  # refernace to all options, including all defined in this tree

  mod_cfg  # referance to this mods own config

  *all normall module args*

  *all exrtra args passed to the loader*
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
        else if all isList values
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
  get-globals = modules_data:
    recursiveMerge ((
      builtins.map
        (x: x.global)
        (builtins.attrValues
          modules_data.module.sub_modules or {}
	)
      ) ++ [ modules_data.global ]
    );


  formatt-module-data = data:
    if (data.is_module or false)
      then if data ? options
        then if data.options == {}
          # Modules shuld, by design only change stuff if the're given
          # options. So one whithout any is ether useless or is changing
          # stuff when not explicitly told to
          then builtins.throw "module has no options"
          else {
            module = {
              sub_modules = {};
              options = data.options;
            };
            global = {
              config = data.config or {};
            };
          }
        else "module missing options attribute"
      else null;  # (builtins.trace (builtins.toJSON data) null);

  # gets the modules data by acsessing the assigned pos for
  # the module with recursive calls to getAttr
  # @example
  # get-specific-module-data modules_data ["a"] -> modules_data.module.sub_modules.a
  get-module-data = modules_data: module_pos:
    rec-get-attr modules_data (
      builtins.concatLists
        builtins.map 
	  (x: ["module" "sub_modules" x])
	  module_pos
    );

  # takes a file with a module and evaluates it's contens
  # then merges said content with modules_data

  # this is that is normally passed to module_args:
  # [ "config" "inputs" "lib" "modulesPath" "options" "specialArgs" ]
  eval-module-file = {
    module_data_pos,
    inp_modules_data,
    module_path,
    module_args,
  }:
    let 
      config = (get-globals inp_modules_data).config; 
      # config = recursiveMerge [
      #  (only-part modules_data "config")  # the module.config
      #  (get-globals modules_data).config  # the 
      # ]
      modules_data = formatt-module-data (
        (import module_path) (module_args // {
          modulesPath = module_path;
          mod_cfg = (rec-get-attr config module_path);
	  config = config;
        })
      );
    in if builtins.typeOf modules_data == "string"
      then builtins.throw "\"${modules_data}\" at ${module_path}"
      else modules_data;

  # trace-return = id: x: (builtins.trace (builtins.toJSON [id x]) x);
  # trace-type = id: x: (builtins.trace builtins.typeOf (x 1) x);

  # (this is done lazily to allow for module to accses eatchothers data)
  eval-module-struct = {
    nix_file_struct,
    modules_data_inp,
    module_data_pos,
    module_args
  }:
    rec {
      modules_data = (
        if ((builtins.typeOf nix_file_struct) != "set")
          then eval-module-file {
            module_data_pos = (module_data_pos);  # where the data for the module is stored
            inp_modules_data = (recursiveMerge [modules_data modules_data_inp]);  # all data
            module_path = nix_file_struct; # path of module
            module_args = module_args; 
	  }          
	  else  # handler sub module dir
            let
              sub_module_data = filterAttrs
                (name: contens: contens != null)
                (builtins.mapAttrs
                  (part_name: part: 
		    eval-module-struct {
                      nix_file_struct = part;
                      modules_data_inp = recursiveMerge [modules_data modules_data_inp];
                      module_data_pos = (module_data_pos ++ [part_name]);
                      module_args = module_args;
                    }
                  )
                  nix_file_struct
                );
	      
	      /* default_module = sub_module_data."default" or {};

	      out = {
  		global = { 
		  config = default_module.config or {}; 
		};
		module = { 
		  options = default_module.options or {}; 
		  sub_modules = 
		    builtins.removeAttrs 
		      sub_module_data 
		      ["default"];
		};
	      }; */
	      
            in recursiveMerge [
              (sub_module_data."default" or {
	        global.config = {};
		module.options = {};
	      }) { 
	        module.sub_modules = 
                  builtins.removeAttrs 
		    sub_module_data 
		    ["default"];
	      }
	    ] 
      );
    }.modules_data;

  # All kwargs passes to eval-module-tree are passed onto
  # all sub-modules.
  load-modules = mod_loader_cfg:
    {config, options, pkgs, modulesPath}@mod_inp:
      let 
	modules = rec {
          scope = mod_loader_cfg.scope or null;
	  nix_file_struct = if scope == null 
	    then get-rec-nix-file-struct mod_loader_cfg.src
	    else {"${scope}" = get-rec-nix-file-struct mod_loader_cfg.src;};

          modules = (eval-module-struct {
            nix_file_struct = nix_file_struct ;# nix_file_struct;
            modules_data_inp = recursiveMerge [
	      { inherit config options; } 
	      modules
	    ];
            module_data_pos = [];  # scope];
            module_args = mod_inp;
	  });
        }.modules;
      in modules; /*{  # this is the resulting module scope
        options = only-part modules ["module" "options"];
        config = (get-globals modules).config;
      }; */
}

/*
{  # this is the resulting module scope
        options = {
	  "${scope}": only-part 
	    modules 
	    ["module" "options"]
	};
        config = {
	  "${scope}": 
	    (get-globals modules).config
	};
      };
*/

  # this is what is given to modules by nix's module system (by default)
  # [ "config" "inputs" "lib" "modulesPath" "options" "specialArgs" ]


