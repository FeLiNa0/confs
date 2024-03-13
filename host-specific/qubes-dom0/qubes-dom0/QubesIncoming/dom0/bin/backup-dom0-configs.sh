#!/bin/sh
set -eo pipefail
FILES="bin .config/fish/config.fish .bashrc .xscreensaver"
TARGET="$1"
if [ -z "$TARGET" ]; then
	echo "USAGE: $0 [target_qube_name]"
	exit 1
fi


echo "Copying: $FILES"
ls -lah $FILES

set -x
cd "$HOME"
qvm-copy-to-vm "$TARGET" $FILES
echo "Backed up to $TARGET"

