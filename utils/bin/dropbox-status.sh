#!/bin/sh

# Set DEBUG=true for more output
DEBUG="${DEBUG:-false}"

DROPBOX_LOCATION="${DROPBOX_LOCATION:-$HOME/Dropbox}"

if command -v dropbox > /dev/null; then
  dropbox status
else
  echo "Warning! 'dropbox' utility is not available in \$PATH."
fi

if [ "$DEBUG" == "true" ] ; then
  set -x
fi

du --summarize --bytes --human-readable "$DROPBOX_LOCATION"
tree "$DROPBOX_LOCATION" | tail --lines=1
# Use 'find' to list most recently modified files and directories
# -mmin - "File's data was last modified less than, more than or exactly n minutes ago."
# -cmin - "File's status was last changed less than, more than or exactly n minutes ago." 
# %Tc - print timestamp in current locale (status change timestamp?)
# %t - print timestamp in C locale (???)
# %p - print absolute filepath
FIND_FLAGS="-mmin +60 -printf %T@\t%Tc\t%-10p\n"
echo
echo "Last 10 recently modified directories"
find "$DROPBOX_LOCATION" $FIND_FLAGS -type d | sort -n | tail -n10

echo
echo "Last 10 recently modified files"
find "$DROPBOX_LOCATION" $FIND_FLAGS -type f | sort -n | tail -n10
