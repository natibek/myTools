#!/usr/bin/env bash

for monitor in $(xrandr | grep -w "connected" | awk '$1 !~ /eDP/ && $1 !="" {print $1}')
do
  xrandr --output $monitor --auto --above eDP
done

eDP_monitor=$(xrandr | grep -w "connected" | awk '$1 ~ /eDP/ {print $1}')
host=$(neofetch --off | awk '$1 ~ /Host/ {print $2}')

if [ "$host" = "Levono" ]; then
  xrandr --output "$eDP_monitor" --mode 1920x1080
fi

