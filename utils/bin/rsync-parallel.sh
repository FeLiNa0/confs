#!/bin/sh
 
# SETUP OPTIONS
export SRC="${SRC:$1}"
export DEST="${DEST:$2}"
export THREADS="${THREADS:-8}"

# 0. LIMIT THE IO PRIORITY
# 1. RSYNC DIRECTORY STRUCTURE
# 2. FIND ALL FILES AND PASS THEM TO MULTIPLE RSYNC PROCESSES
ionice -c2 rsync -zr -f"+ */" -f"- *" "$SRC" "$DEST" \
    && cd $SRC  &&  ionice -c2 find . ! -type d -print0 | xargs -0 -n1 -P$THREADS -I% rsync -az % "$DEST/%"
