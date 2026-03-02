#!/usr/bin/bash
### Integer output:
### tr ' ' '\n' | awk '{ x+=$0 } END { print x }'

tr ' ' '\n' | awk '{ x+=$0 } END { printf "%.16f\n", x }'
