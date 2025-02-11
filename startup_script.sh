#!/usr/bin/env bash

source ~/.bashrc
sleep 1

 
i3-msg workspace 6
gnome-terminal --working-directory=$UCS_ROOT -- bash -c 'nvim .; exec bash'
sleep 1

i3-msg workspace 7
gnome-terminal --working-directory=$CUR_PROJECT -- bash -c 'nvim .; exec bash'
sleep 1

i3-msg workspace 8
gnome-terminal --working-directory=$WORK_DIR1 -- bash -c "nvim .; exec bash"
gnome-terminal --working-directory=$WORK_DIR2 -- bash -c "nvim .; exec bash"
microsoft-edge --new-window https://github.com/infleqtion/client-superstaq https://github.com/infleqtion/server-superstaq https://teams.microsoft.com/v2/& 
sleep 2

i3-msg workspace 9
microsoft-edge --new-window https://www.notion.so/TODO-f1b831f184f14b52ae99200fdfafb68c & 
sleep 2

i3-msg workspace 1
firefox https://outlook.office.com &
sleep 2

