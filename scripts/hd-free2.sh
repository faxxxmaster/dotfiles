#!/bin/bash

# Ausgabe eines Statusbalkens
status_bar() {
    if [ $# -ne 1 ]; then
        exit
    fi

    local drive="$1"
    local used=$(df "$drive" | tail -n 1 | awk '{print $3}')
    local total=$(df "$drive" | tail -n 1 | awk '{print $2}')
    local terminal_width=$(tput cols)
    local bar_length=$(($terminal_width - 9))
    local percentage=$(echo "$used $total 100" | awk '{printf "%i", $1/$2*$3}')

    local color_code
    if ((percentage < 90)); then
        color_code="\033[1;33m"
    elif ((percentage < 80)); then
        color_code="\033[1;32m"
    else
        color_code="\033[1;31m"
    fi

    local filled_length=$(echo "$used $total $bar_length" | awk '{printf "%i", $1/$2*$3}')
    printf "Disk usage: %s\n%s[%s" "$drive" "$color_code" "$drive"
    for ((i=0; i < filled_length; i++)); do
        printf "#"
    done
    for ((i=filled_length; i < bar_length; i++)); do
        printf "-"
    done
    printf "%s]%3d%%\033[0m\n" "$color_code" "$percentage"
}

# Laufwerke ermitteln
drives=$(mount|grep -E '^\/'|awk '{print $3}')

for var in $drives
do
 statusbalken "$var"
done
