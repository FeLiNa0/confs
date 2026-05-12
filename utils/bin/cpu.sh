#!/bin/bash
vmstat 1 3 | awk 'NR>2{cpu=100-$15; max=(cpu>max)?cpu:max; sum+=cpu; count++}END{print "Max " max "% Avg " int(sum/count) "%"}'
