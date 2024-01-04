#!/bin/sh
# Set window title
echo -ne "\033]k9s | $(kubectl config current-context)\007"
exec k9s $@
