#!/bin/bash

# delete extraneous files from destination
ROOT=$(get-backup-root.sh)/$(date +%Y-%m)

set -x

mkdir -p $ROOT/bin

RSYNC_OPTS="--archive --human-readable --progress --delete-after --verbose --recursive --ignore-missing-args"

apt list --installed | grep -v automatic | cut -f1 -d'/' > $ROOT/apt-installed

rsync $RSYNC_OPTS $HOME/bin/ $ROOT/bin

mkdir -p $ROOT/history/
rsync $RSYNC_OPTS \
  /var/log/apt/history.log \
  ~/.local/share/fish/fish_history \
  ~/.bash_history \
  ~/.zsh_history \
  $ROOT/history

ls -1 ~/pf/*/* ~/src/*/* > "$ROOT/src_ls_star_star_filenames"

