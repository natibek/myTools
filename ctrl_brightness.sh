#! /usr/bin/env bash
# Script for changing the brightness on the embedded display monitor. Issues with brightnessctl and light for ubuntu with i3.

if [ "$#" -ne 1 ]; then
  exit 1
fi

arg="$1"
eDP_monitor=$(xrandr | grep -w "connected" | awk '$1 ~ /eDP/ {print $1}')
cur_brightness=$(xrandr --verbose | awk '/Brightness/ { print $2; exit}')

host=$(cat /etc/hostname)

if [ "$host" = "archlinux" ]; then
  max=1.5
else
  max=2 
fi

if [ "$arg" = "-brightness" ]; then
  echo "$cur_brightness"
  exit 0
fi

if [ "$arg" = "-increase" ] && (( $(echo "$cur_brightness + 0.05 < $max" | bc -l) )); then
  new_brightness=$(echo "$cur_brightness + 0.05" | bc -l)
  xrandr --output "$eDP_monitor" --brightness "$new_brightness"
  exit 0
fi

if [ "$arg" = "-decrease" ] && (( $(echo "$cur_brightness - 0.1 > 0.3" | bc -l) )); then
  new_brightness=$(echo "$cur_brightness - 0.1" | bc -l)
  xrandr --output "$eDP_monitor" --brightness "$new_brightness" 
  exit 0
fi

