#!/bin/sh
set -x
ssh -p 46666 -L 11434:127.0.0.1:11434 felina@7918.roguh.com
