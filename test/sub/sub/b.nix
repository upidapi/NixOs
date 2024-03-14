{
  config,  # referancees to all other modules
  mod_cfg,  # referance to this mods own config 
  ...
}: {
  # signals that this is a module
  is_module = true;

  options = {
    default_opt = "b_opt";
  };

  config = {
    test.sub.b.inp = "b_inp";
    test.sub.b.inp2 = "b_inp2";
    # test.a.default_cfg = "b_cfg" + config.test.a.inp;
  };
}
