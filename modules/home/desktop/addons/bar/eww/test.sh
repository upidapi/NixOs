#!/usr/bin/env zsh

_MIC=$(pactl info | grep "Default Source" | awk '{print$3}')

vol_master(){
    pamixer ${1}
    pactl subscribe |
    grep --line-buffered "Event 'change' on ${2} " |
    while read -r _; do
        pamixer ${1} | cut -d " " -f1
    done
}

mic_state(){
    pamixer --source $_MIC --get-mute | awk '{print}'
}

mic_toggle() {
    _PASS=$(mic_state)

    if [[ $_PASS == "false" ]]; then
        eww update mic_initial="true"
        pactl set-source-mute @DEFAULT_SOURCE@ true
    else
        eww update mic_initial="false"
        pactl set-source-mute @DEFAULT_SOURCE@ false
    fi
}

mic_volume (){
    pamixer --source $_MIC --get-volume
    pactl subscribe |
    grep --line-buffered "Event 'change' on source " |
    while read -r _; do
        pamixer --source $_MIC --get-volume
    done
}

_filter(){
    stdbuf -oL -eL uniq | cat
}

vol_master "--get-volume" "sink" # | _filter
vol_master "--get-mute" "sink" # | _filter
mic_state
# mic_toggle
# pamixer --source $_MIC -i 5
# pamixer --source $_MIC -d 5
mic_volume # | _filter
