#!/bin/bash
ROOTDIR="$(projectroot.sh)"
ROOT_STATUS_CODE="$?"
PROJECTNAME_PRINT_PWD=true
PATTERN='s#'"$ROOTDIR"'##'

if [ "$ROOT_STATUS_CODE" != 0 ]; then
  echo ""
  exit "$ROOT_STATUS_CODE"
else
  # Replace common prefixes
  PROJECTNAME="$(basename "$ROOTDIR" |
      sed "s/^pfc_\|powerflex_edge_\|powerflex_cloud_\|powerflex_//"
    )"
  if [ "$PROJECTNAME_PRINT_PWD" != "true" ] && [ "$PROJECTNAME" = "$(basename $PWD)" ]; then
    echo "$PROJECTNAME"
  else
    echo "$PROJECTNAME $(echo "$PWD" | sed "$PATTERN")"
  fi
fi
