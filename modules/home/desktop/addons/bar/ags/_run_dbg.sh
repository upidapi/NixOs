#!/bin/env bash

run_code() {
	# to run this manually use
	ags quit

	cd || return

	color_cfg="$(realpath .config/ags/colors.scss)"
	ags_src="$NIXOS_CONFIG_PATH/modules/home/desktop/addons/bar/ags/src"

	mkdir .config/ags-dbg &>/dev/null

	cp -rf "$ags_src"/* .config/ags-dbg

	chmod +w .config/ags-dbg/colors.scss
	cp "$color_cfg" .config/ags-dbg/colors.scss

	ags run -d "$(realpath ./.config/ags-dbg)"
}

run_on_change() {

	function execute() {
		# clear
		# echo "$@"
		echo "run ags"
		eval "$1"
		sleep 0.2
	}

	execute "$2"

	inotifywait --quiet --recursive --monitor --event modify --format "%w%f" "$1" |
		while read change; do
			execute "$2"
		done

}

run_on_change "$(realpath ./src)" "run_code &"

# while true; do
# 	run_code &
# 	echo "press to rerun"
# 	read -n 1
# done
