#!/bin/bash

ROOT=$(get-backup-root.sh)/games/$(date +%Y-%m)

mkdir -p $ROOT/game-backups

# delete extraneous files from destination
RSYNC_OPTS="--archive --human-readable --delete-after --recursive --ignore-missing-args"

echo BACKUP WEBFISHING

# $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/Roaming/Godot/app_userdata/webfishing_2_newver
rsync $RSYNC_OPTS \
  $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/ \
  $ROOT/game-backups/Webfishing

echo BACKUP FINAL FANTASY
# $HOME/.steam/steam/steamapps/compatdata/1173770/pfx/drive_c/users/steamuser/Documents/My Games/FINAL FANTASY PR
rsync $RSYNC_OPTS \
  "$HOME/.steam/steam/steamapps/compatdata/1173770/pfx/drive_c/users/steamuser/Documents/My Games/FINAL FANTASY PR" \
  $ROOT/game-backups/FinalFantasy

echo BACKUP CALL OF DUTY 2 2005
rsync $RSYNC_OPTS \
  "$HOME/.local/share/Steam/steamapps/common/Call of Duty 2/main/players" \
  $ROOT/game-backups/COD2_2025
