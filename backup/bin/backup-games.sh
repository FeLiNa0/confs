#!/bin/bash

ROOT=$(get-backup-root.sh)/$(date --iso-8601)

set -x

mkdir -p $ROOT/game-backups

# delete extraneous files from destination
RSYNC_OPTS="--archive --human-readable --progress --delete-after --verbose --recursive --ignore-missing-args"

# $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/Roaming/Godot/app_userdata/webfishing_2_newver
rsync $RSYNC_OPTS \
  $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/ \
  $ROOT/game-backups
