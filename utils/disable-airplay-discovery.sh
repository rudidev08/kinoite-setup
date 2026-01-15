#!/usr/bin/env bash
# Disable AirPlay (RAOP) device discovery in PipeWire
# https://docs.getaurora.dev/guides/disable-airplay-discovery/

set -euo pipefail

conf_dir="$HOME/.config/pipewire/pipewire.conf.d"
conf_file="$conf_dir/disable-raop.conf"

mkdir -p "$conf_dir"
echo 'context.properties = { module.raop = false }' > "$conf_file"

echo "AirPlay discovery disabled. Restart to apply."
