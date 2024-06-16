#!/usr/bin/env bash

gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false # hide the dock

for win in $(wmctrl -lix | grep -v gnome-terminal-server.Gnome-terminal | cut -d' ' -f1); # iterate through all the windows and kill them except for the terminal
do
    wmctrl -i -c $win
done

curTTY=$(ps a | grep "ps a" | grep -v grep |cut -d' ' -f4) # gets the current terminal the program is running on

for pid in $(ps a | grep bash | grep -v "$curTTY" | cut -d' ' -f3); # get the pid of all the other terminals
do
    kill -9 $pid
done

kill -9 $PPID

