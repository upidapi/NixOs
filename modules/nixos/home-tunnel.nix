/*
Some home manager options / modules need to change
some nixos configurations to work. For example the
zsh module has to set the shell of the user. This
module is a type of hook that uses the home-manager
conf to generate some nixos config

Normally this might be a security problem, but since
the whole config is in the same scope (has the same
perms) This isn't a problem

Idk if all tunnels should be here or if this is just
a "other" category, currently the nixos persist.nix
module does the same thing on it's own

this thing is not used but preserved incase i need it
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

  users_data = config.home-manager.users;
  users = builtins.attrNames users_data;

  # mapUsersData = func: builtins.mapAttrs func users_data;
  # mapUsers = func: builtins.map func users;

  isEmpty = data:
    builtins.all (
      val: val == {}
    )
    (builtins.attrValues data);

  # usage
  # filterUsers (name: data: bool) => names where true
  filerUsers = func:
    builtins.attrNames (
      lib.filterAttrs
      func
      users_data
    );

  /*
  filerUsers = func:
    builtins.attrNames (
      lib.filterAttrs
      func
      {a=true; b=false; c=true;}
    )
  */
  anyUser = func: (
    (
      builtins.length
      (filerUsers func)
    )
    != 0
  );

  setIf = boolean: data:
    if ! boolean
    then {}
    else data;

  # if it has the key null, then it's ignored
  # mapFullUsers (name: data: [key val])
  mapFullUsers = with builtins;
    func: (
      listToAttrs (
        map
        (data: {
          name = elemAt data 0;
          value = elemAt data 1;
        })
        (
          builtins.filter
          (data: (elemAt data 0) != null)
          (
            attrValues (
              mapAttrs
              func
              users_data
            )
          )
        )
      )
    );
in {
  options.modules.nixos.home-tunnel =
    mkEnableOpt
    ''enables the home-manager -> nixos tunnel'';

  config = mkIf enabled (
    lib.mkMerge [
      # fix wayland on nvidia
      (
        mkIf (
          anyUser (
            _: data: data.modules.home.desktop.wayland.enable
          )
          && config.modules.nixos.hardware.gpu.nvidia.enable
        ) {
          environment.variables = {
            WLR_NO_HARDWARE_CURSORS = "1";
            LIBVA_DRIVER_NAME = "nvidia";
            XDG_SESSION_TYPE = "wayland";
            GBM_BACKEND = "nvidia-drm";
            # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          };
        }
      )

      # sets and enables zsh for the users that has
      # the home manager module enabled
      (
        let
          zsh_users = mapFullUsers (
            name: data: let
              zsh_usr_cfg = data.modules.home.cli-apps.zsh;
            in [
              (
                if (zsh_usr_cfg.enable)
                then name
                else null
              )
              (
                if ! zsh_usr_cfg.set-shell
                then {}
                else {
                  shell = pkgs.zsh;
                }
              )
            ]
          );
        in
          mkIf (! isEmpty zsh_users)
          {
            users.users = zsh_users;
            programs.zsh.enable = true;
            environment.pathsToLink = ["/share/zsh"];
          }
      )
    ]
  );
}
