#!/bin/bash

ROOT=$(get-backup-root.sh)/$(date +%Y-%m)

# set -x

# delete extraneous files from destination
# print progress
# etc
RSYNC_OPTS="--archive --human-readable --delete-after --recursive --ignore-missing-args"

echo "BACKUP all installed packages WITH pacman -Qie"
pacman -Qie --native > $ROOT/pacman-Qie
pacman -Qie --foreign > $ROOT/pacman-Qie-AUR

echo "BACKUP all custom executables IN ~/bin"
mkdir -p $ROOT/bin
rsync $RSYNC_OPTS $HOME/bin/ $ROOT/bin

echo "BACKUP all screen layouts IN ~/.screenlayout"
rsync $RSYNC_OPTS $HOME/.screenlayout/ $ROOT/dotscreenlayout

echo "BACKUP all shell history"
mkdir -p $ROOT/history/
rsync $RSYNC_OPTS \
  ~/.local/share/fish/fish_history \
  /var/log/pacman.log \
  ~/.bash_history \
  ~/.zsh_history \
  $ROOT/history

echo "BACKUP list of all src top-level files WITH ls"
ls -1 ~/{pf,src}/*/* > "$ROOT/src_ls_star_star_filenames"

echo "BACKUP all changed sys files in / WITH pacman -Qii"
mkdir -p $ROOT/additional-files-pacman-Qii
ADDITIONAL_CHANGED_FILES="/usr/share/thumbnailers/webp.thumbnailer $HOME/.local/share/mime/packages/webp.xml"
pacman -Qii > $ROOT/pacman-Qii.txt
rsync --relative $RSYNC_OPTS \
  $ADDITIONAL_CHANGED_FILES \
  $(cat $ROOT/pacman-Qii.txt | \
    grep '\[modified\]' | \
    rev | \
    awk '{print $2}' | \
    rev) \
  $ROOT/additional-files-pacman-Qii

date
echo BACKUP COMPLETE
