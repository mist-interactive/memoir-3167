#! /bin/bash

mkdir -p /root/build/server/
godot --headless --path /root/memoir-3167 --export-release "Linux" "/root/build/server/memoir-3167.bin"
/root/build/server/memoir-3167.bin

exec "$@"
