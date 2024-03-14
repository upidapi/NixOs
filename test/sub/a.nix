{
  config,  # referancees to all other modules
  mod_cfg,  # referance to this mods own config 
  ...
}: {
  # signals that this is a module
  is_module = true;

  options = {
    default_opt = "a_opt";
  };

  config = {
    test.a.inp = "a_inp";
    test.sub.b.default_cfg = "a_cfg" + config.test.sub.b.inp;
  };
}

