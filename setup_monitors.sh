#!/usr/bin/env bash

for monitor in $(xrandr --listmonitors | awk '$4 != "eDP" && $4 !="" {print $4}')
do
  xrandr --output $montor --auto --above eDP
done
