{options, config, ...}: {
  options = {
    val_a = "inside a";
  };
  
  config = {
    val_a_out = b.options.val_b;
  };
}
