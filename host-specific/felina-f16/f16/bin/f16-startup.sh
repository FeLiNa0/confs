#!/bin/sh
INPUTMODULE=inputmodule-control_cli_linux_v0.1.8.7
# $INPUTMODULE led-matrix --clock

# Less bright
$INPUTMODULE led-matrix --brightness 5

# Start an animation
# Halt with
# $INPUTMODULE led-matrix --stop-game
$INPUTMODULE led-matrix --start-game game-of-life --game-param glider