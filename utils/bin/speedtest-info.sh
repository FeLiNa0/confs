#!/bin/sh
echo "$(speedtest-cli --json | jq '.client.ip + "'" "'" + .server.cc,(.ping | floor),(.download/1e3 | floor)/1e3')" | sed 's/"//g'