#!/bin/bash
set -x

if command -v pacman > /dev/null; then
    backup-this-pacman-machine.sh
elif command -v dnf > /dev/null; then
    backup-this-dnf-machine.sh
elif command -v apt > /dev/null; then
    backup-this-apt-machine.sh
fi

if command -v backup-$(hostname).sh; then
    backup-$(hostname).sh
fi
