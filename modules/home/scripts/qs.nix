/*
plans


# always commit changes when switching
#  unless it directly fails, i.e no generation is created


# https://www.reddit.com/r/NixOS/comments/e3tn5t/reboot_after_rebuild_switch/
# Warn if the generation may have changed some options
# that only take effect after reboot. This is to avoid a
# generation from a

# maby give the option to reboot when it detects that
# it might be needed

qs
  <commit msg>
  [--help]
    Print this help msg

  [-h | --host <host name>]
    Select the host to switch to
    <host name> defults to the last host

  [-t | --trace]
    pass --trace to nixos-rebuild

  [-a | --append <feature (branch) name>]
    append / connect this change to the last
    should be used to fix a bug in a generation
    if last switch was a qa, then use the name from said qs

    To organice things, the first qa starts a new branch
    and adds the commit before it to it.
    The branch is remerged when a qs is used again.
  
  [-d | --debug <debug msg (branch name)>]
    basically -a but soly for debuging
    only one (manuall) commit msg, (the first one)
    
    Allows you to really quicky iterate over generations
    to find some bug, in this mode you shuld preferably only 
    fix one thing


Sub commands:
  e | edit
    cd into nixos config, open editor

  g | goto
    cd into nixos config

qa # alias for "qs --append"
qd # alias for "qs --debug --trace"


# do this in python

# show diff since last commit
git --no-pager diff HEAD

# terminate if the nixos-rebuld fails
*/
{
  config,
  lib,
  pkgs,
  my_lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (my_lib.opt) mkEnableOpt;
  cfg = config.modules.home.scripts.qs;
in {
  options.modules.home.scripts.qs =
    mkEnableOpt
    "Whether or not to add the qs command";

  # qs i.e quick switch
  # just a shorthand for regen-nixos
  config = mkIf cfg.enable {
    modules.home.scripts.regen-nixos.enable = true;
    home.packages = [
      (pkgs.writeShellScriptBin "qs" ''
        # we shuld try to store the current profile
        # and use that as a default
        if [[ $# -eq 0 ]];
          then profile="default";
          else profile="$1";
        fi

        regen-nixos "$profile" "--no-commit"
      '')
    ];
  };
}
