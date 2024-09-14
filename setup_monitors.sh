#!/usr/bin/env bash

for monitor in $(xrandr | grep -w "connected" | awk '$1 !~ /eDP/ && $1 !="" {print $1}')
do
  xrandr --output $monitor --auto --above eDP
done

eDP_monitor=$(xrandr | grep -w "connected" | awk '$1 ~ /eDP/ {print $1}')
# cleaning up string in bash is terrible 

# host=$(neofetch --off | grep "Host" | cut -d: -f2)
# host=$(echo "$host" | tr -cd '[:print:]')
# host=$(echo "$host" | sed 's/\[0m//g')
# host=$(echo "$host" | tr -d '\n')
# host=$(echo "$host" | tr -s ' ')
# host=$(echo "$host" | xargs)
# host=$(echo "$host" | sed 's/[[:space:]]*$//')
# host=$(echo "$host" | awk '{$1=$1;print}')

# echo "$host" | od -c
# echo "<$host>"
# echo "<83AW Levono Slim Pro 7 14APH8>"

host=$(cat /etc/hostname)

if [ "$host" = "slim" ]; then
  xrandr --output "$eDP_monitor" --mode 1680x1050
fi

