#!/bin/sh
exec [ "$(uname -m)" != "x86_64" ] && uname -m
