#!/bin/bash

ROOT=$(get-backup-root.sh)/$(date --iso-8601)

mkdir -p $ROOT/game-backups

# delete extraneous files from destination
RSYNC_OPTS="--archive --human-readable --delete-after --recursive --ignore-missing-args"

echo BACKUP WEBFISHING

# $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/Roaming/Godot/app_userdata/webfishing_2_newver
rsync $RSYNC_OPTS \
  $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/ \
  $ROOT/game-backups
