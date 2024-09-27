#!/bin/bash

# Ausgabe eines Statusbalkens
statusbalken() {
 if [ $# != 1 ]
  then
   exit;
 fi

 used=$(df "$1"|tail -n 1|awk '{print $3}')
 total=$(df "$1"|tail -n 1|awk '{print $2}')

 e=$(printf "\033")
 end="$e[0m"
 COLUMNS=$(tput cols)
 COLUMNS=$((COLUMNS-9))

 PERCENT=$(echo "$used $total 100"|awk '{printf ("%i", $1/$2*$3 )}')
 percent=$(echo "$used $total $COLUMNS"|awk '{printf ("%i", $1/$2*$3 )}')

 COLOR="$e[1;31m"
 if [[ $PERCENT -lt 90 ]] ;then
  COLOR="$e[1;33m"
 fi
 if [[ $PERCENT -lt 80 ]] ;then
  COLOR="$e[1;32m"
 fi

 printf " Disk usage: %s\n ${COLOR}[${end}" "$1"
 for (( i=0; i< percent; i++ ))
 do
  printf "%b" "#"
 done

 for (( i=percent; i<COLUMNS; i++ ))
 do
  printf "%b" "-"
 done
 printf "${COLOR}]${end}%3d%%\n" "$PERCENT"
}

# Laufwerke ermitteln
drives=$(mount|grep -E '^\/'|awk '{print $3}')

for var in $drives
do
 statusbalken "$var"
done
