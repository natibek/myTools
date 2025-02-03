#!/usr/bin/env bash
dconf dump / >~/dotfiles/gnome-dconf-backup.bak

(
  cd ~/dotfiles || exit
  git add gnome-dconf-backup.bak &&
    git commit -m "Backup latest dconf preferences" &&
    git push
)
