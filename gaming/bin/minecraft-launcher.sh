#!/bin/sh
exec gamemoderun prismlauncher || exec "Lunar Client-3.2.6.AppImage" || notify-send "No minecraft launcher found"
