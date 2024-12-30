#!/bin/env bash

run_code() {
	# to run this manually use
	ags quit &>/dev/null

	cd || return

	color_cfg="$(realpath .config/ags/colors.scss)"
	ags_src="$NIXOS_CONFIG_PATH/modules/home/desktop/bar/ags/src"

	mkdir .config/ags-dbg &>/dev/null

	cp -rf "$ags_src"/* .config/ags-dbg

	if [ -f .config/ags-dbg/colors.scss ]; then
		chmod +w .config/ags-dbg/colors.scss
		cp "$color_cfg" .config/ags-dbg/colors.scss
	fi

	ags run -d "$(realpath ./.config/ags-dbg)"
}

last_run=0

run_on_change() {

	function execute() {
		# clear
		# echo "$@"
		echo 
		echo 
		echo 
		echo 
		echo 
		echo "run ags"
		eval "$1"
	}

	execute "$2"

	inotifywait --quiet --recursive --monitor --event modify --format "%w%f" "$1" |
		while read -r _; do
            cur_time=$(date +%s%3N)
            if ((cur_time - last_run > 500)); then 
                last_run=$cur_time
                execute "$2"
            fi
		done

}

run_on_change "$(realpath ./src)" "run_code &"

# while true; do
# 	run_code &
# 	echo "press to rerun"
# 	read -n 1
# done
