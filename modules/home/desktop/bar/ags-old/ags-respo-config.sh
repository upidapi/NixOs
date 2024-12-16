#!/bin/env bash
# to run this manually use

ags --quit

cd ~ || exit
color_cfg="$(realpath .config/ags/colors.scss)"
mkdir -p .config/ags-dbg

ags_src="$NIXOS_CONFIG_PATH/modules/home/desktop/addons/bar/ags-old/src"
cp -r "$ags_src"/* .config/ags-dbg

# its copied with read only perms for some reason
chmod +w .config/ags-dbg/colors.scss 
rm .config/ags-dbg/colors.scss
cp "$color_cfg" .config/ags-dbg/colors.scss 

ags -c ./.config/ags-dbg/config.js
