rec {
  module_paths = {
    a = ./a.nix;
    b = ./b.nix;
  };
  modules = builtins.mapAttrs 
    (_: module:
      (import module) {inherit modules;}
    )
    module_paths;
}


/* rec {
  inp = 0;
  self = import ./main.nix;
  out = self.inp + 1;
} */
