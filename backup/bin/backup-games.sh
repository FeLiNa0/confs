#!/bin/bash

ROOT=$(get-backup-root.sh)/$(date +%Y-%m)

mkdir -p $ROOT/game-backups

# delete extraneous files from destination
RSYNC_OPTS="--archive --human-readable --delete-after --recursive --ignore-missing-args"

echo BACKUP WEBFISHING

# $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/Roaming/Godot/app_userdata/webfishing_2_newver
rsync $RSYNC_OPTS \
  $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/ \
  $ROOT/game-backups/webfishing

if [ -f "$HOME/.steam/steam/steamapps/common/Call of Duty\ 2/main/players/" ] ; then
echo BACKUP CALL OF DUTY 2 2005
rsync $RSYNC_OPTS \
  "$HOME/.steam/steam/steamapps/common/Call of Duty\ 2/main/players/" \
  $ROOT/game-backups/call_of_duty_2_2005
fi

LILKIT="/home/roguh/.steam/steam/steamapps/compatdata/1177980/pfx/drive_c/users/steamuser/AppData/LocalLow"
if [ -d "$LILKIT" ] ; then
echo BACKUP LKBC 2005
rsync $RSYNC_OPTS \
  "$LILKIT" \
  $ROOT/game-backups/little_kitten_big_city
fi
