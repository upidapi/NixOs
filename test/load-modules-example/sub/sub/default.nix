{
  config,  # referancees to all other modules
  mod_cfg,  # referance to this mods own config 
  ...
}: {
  # signals that this is a module
  is_module = true;

  options = {
    default_opt = "sub_def_opt";
  };

  config = {}
}
