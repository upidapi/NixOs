rec {
  a = import ./a.nix;

  options = {
    val_b = a.options.val_a;
  };
  
  config = {
    val_b_out = a.options.val_a;
  };
}
