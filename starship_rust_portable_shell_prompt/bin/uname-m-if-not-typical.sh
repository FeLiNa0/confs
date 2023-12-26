#!/bin/sh
if [ "$(uname -m)" != "x86_64" ]; then
    uname -m
else
    exit 1
fi
