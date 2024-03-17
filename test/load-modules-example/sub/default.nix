{
  config, # referancees to all other modules
  mod_cfg, # referance to this mods own config
  ...
}: {
  # signals that this is a module
  is_module = true;

  options = {
    default_opt = "default_opt";
  };

  config = {
    default_cfg = "default_cfg";
  };
}
