
let 
  nixpkgs = import <nixpkgs> {};
  inherit (builtins) readDir baseNameOf match mapAttrs;
  inherit (nixpkgs.lib) filterAttrs; 
  
  get-rec-nix-file-struct = let 
    is-file-kind = kind: kind == "regular";
    is-symlink-kind = kind: kind == "symlink";
    is-directory-kind = kind: kind == "directory";
    is-unknown-kind = kind: kind == "unknown";

    is-nix-file = name: kind: if is-file-kind kind then nixpkgs.lib.hasSuffix ".nix" name else false;
  
    get-rec-nix-file-struct = path:
      filterAttrs (
        (name: contens: contens != null)
        mapAttrs (
          name: kind:
            if is-directory-kind kind
            then get-rec-nix-file-struct "${path}/${name}"

            else if is-nix-file (name kind)
              then "${path}/${name}"
              else null
          readDir path
        )
    );

  get-rec-combined-mod-opts = nix-file-struct: 
    map (
      (name: val:
        if builtins.typeOf val "lambda"
        then (val {}).mod_opts or {}
        else get-rec-combined-mod-opts val
      )
      nix-file-struct
    );

  get-rec-combined-opts = nix-file-struct:
    builtins.listToAttrs (
      nixpkgs.lib.mapAttrsToList
        (name: val:
          if builtins.typeOf val "set"
          then get-rec-combined-opts val
          else (val {}).options or {}
        )
        nix-file-struct
      );
    
  combined-opts = get-rec-combined-opts nix-file-struct

  };
in 
  
