/*
Some home manager options / modules need to change
some nixos configurations to work. For exemple the
zsh module has to set the shell of the user. This
module is a type of hook that uses the home-manager
conf to generate some nixos config

Normally this might be a security problem, but since
the whole config is in the same scope (has the same
perms) This isn't a problem

Idk if all tunnels should be here or if this is just
a "other" catagory, currently the nixos persist.nix
module does the same thing on it's own
*/
{
  config,
  my_lib,
  lib,
  pkgs,
  ...
}: let
  inherit (my_lib.opt) mkEnableOpt;
  inherit (lib) mkIf;
  cfg = config.modules.nixos.home-tunnel;
  enabled = (
    cfg.enable
    && (builtins.hasAttr "home-manager" config)
  );
  # takes a list of attrs and uses func to derive
  # the value of each attr
  mapToAttrs = func: list:
    builtins.listToAttrs (
      builtins.map (
        attr: {
          name = attr;
          value = func attr;
        }
      )
      list
    );

  users = builtins.attrNames config.home-manager.users;
in {
  options.modules.nixos.home-tunnel =
    mkEnableOpt
    ''enables the home-manager -> nixos tunnel'';

  config = mkIf enabled (
    {
    }
    /*
       // (
      # sets and enables zsh for the users that has
      # the home manager module enabled
      let
        zsh_users = (
          builtins.filter
          (
            user: let
              zsh_usr_cfg = user.modules.home.cli-apps.zsh;
            in
              zsh_usr_cfg.enabled && zsh_usr_cfg.setShell
          )
          users
        );
        zsh_users_cfg = (
          mapToAttrs
          (user: {shell = pkgs.zsh;})
          zsh_users
        );
      in
        mkIf (builtins.length zsh_users != 0) {
          users.users = builtins.trace zsh_users_cfg zsh_users_cfg;
          programs.zsh.enable = true;
          environment.pathsToLink = ["/share/zsh"];
        }
    )
    */
  );
}
