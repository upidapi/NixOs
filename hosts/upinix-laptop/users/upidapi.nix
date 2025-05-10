{
  # pkgs,
  # inputs,
  my_lib,
  ...
}: let
  inherit (my_lib.opt) enable enableAnd;
in {
  # Dont change this unless you reinstall from scratch.
  home.stateVersion = "23.11"; # Read comment
  modules.home = {
    suites.all = enable;

    misc.vms = {
      enable = true;
      w11 = enableAnd {
        isoName = "Win11_24H2_Eng_Debloated_x64.iso";
      };
    };
  };
}
