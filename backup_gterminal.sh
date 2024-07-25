#!/usr/bin/env bash
dconf dump /org/gnome/terminal/ > ~/dotfiles/gterminal.preferences

(cd ~/dotfiles || exit; git add gterminal.preferences; git commit -m "Backup latest terminal preferences"; git push;)
