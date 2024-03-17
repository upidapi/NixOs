{
  config, # referancees to all other modules
  mod_cfg, # referance to this mods own config
  ...
}: {
  # signals that this is a module
  is_module = false;

  options = {
    default_opt = "a_opt";
  };

  config = {
    default_cfg = "a_cfg";
  };
}
