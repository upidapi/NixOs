{
  modules,  # referancees to all other modules
  mod_cfg  # referance to this mods own config 
}: {
  # signals that this is a module
  is_module = true;

  options = {
    default_opt = "a_opt";
  };

  conifg = {
    default_cfg = "a_cfg";
  };
}
