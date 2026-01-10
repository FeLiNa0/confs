#!/bin/bash

ROOT=$(get-backup-root.sh)/$(date +%Y-%m)

mkdir -p $ROOT/game-backups

# delete extraneous files from destination
RSYNC_OPTS="--archive --human-readable --delete-after --recursive --ignore-missing-args"

echo BACKUP WEBFISHING
# $HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/Roaming/Godot/app_userdata/webfishing_2_newver
WEBFISH="$HOME/.steam/steam/steamapps/compatdata/3146520/pfx/drive_c/users/steamuser/AppData/Roaming" 
rsync $RSYNC_OPTS \
  "$WEBFISH" $ROOT/game-backups/webfishing

echo BACKUP DARK SOULS II
DS2="$HOME/.steam/steam/steamapps/compatdata/335300/pfx/drive_c/users/steamuser/AppData/Roaming"
rsync $RSYNC_OPTS \
  "$DS2" $ROOT/game-backups/DS2_dark_souls_ii_DarkSoulsII

if [ -f "$HOME/.steam/steam/steamapps/common/Call of Duty\ 2/main/players/" ] ; then
echo BACKUP CALL OF DUTY 2 2005
COD2="$HOME/.steam/steam/steamapps/common/Call of Duty\ 2/main/players"
rsync $RSYNC_OPTS \
  "$COD2" $ROOT/game-backups/call_of_duty_2_2005
fi

LILKIT="$HOME/.steam/steam/steamapps/compatdata/1177980/pfx/drive_c/users/steamuser/AppData/LocalLow"
if [ -d "$LILKIT" ] ; then
echo BACKUP LKBC 2005
rsync $RSYNC_OPTS \
  "$LILKIT" $ROOT/game-backups/little_kitten_big_city
fi

VTMB="$HOME/Games/Heroic/VtMB/Unofficial_Patch/save/"
if [ -d "$LILKIT" ] ; then
echo "BACKUP Vampire the Masquerade Bloodlines (2004)"
rsync $RSYNC_OPTS \
  "$VTMB" $ROOT/game-backups/vtmb_2004
fi
