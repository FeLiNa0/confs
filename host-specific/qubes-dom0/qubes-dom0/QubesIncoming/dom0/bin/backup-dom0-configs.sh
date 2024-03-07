#!/bin/sh
set -eo pipefail
TARGET="$1"
if [ -z "$TARGET" ]; then
	echo "USAGE: $0 [target_qube_name]"
	exit 1
fi

set -x
cd "$HOME"
qvm-copy-to-vm "$TARGET" bin .config/fish .bashrc
echo "Backed up to $TARGET"

