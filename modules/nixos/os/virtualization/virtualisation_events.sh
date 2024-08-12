#!/bin/sh

command=$2

if [ "$command" = "started" ]; then
    notify-send "Starting Windows"
    systemctl set-property --runtime -- system.slice AllowedCPUs=0,1,8,9
    systemctl set-property --runtime -- user.slice AllowedCPUs=0,1,8,9
    systemctl set-property --runtime -- init.scope AllowedCPUs=0,1,8,9
elif [ "$command" = "release" ]; then
    notify-send "Stopping Windows"
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-15
    systemctl set-property --runtime -- user.slice AllowedCPUs=0-15
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-15
fi
