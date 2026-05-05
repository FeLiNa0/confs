#!/bin/bash
free | grep 'Mem:' | awk '{printf("%.1fG RAM", ($3 + $5) / 1000000)}'
printf ' %s STO' "$(df -h / | tail -n1 | cut -d' ' -f9)"
