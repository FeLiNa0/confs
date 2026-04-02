#!/usr/bin/bash
# Silences ttok warnings and allows passing filenames instead of file contents

if ! command -v ttok 2>&1 >/dev/null; then
    echo "pip install ttok plz!"
    exit 1
fi

echo "ttok $@" >&2
python -W ignore "$(which ttok)" "$(cat $@)"
