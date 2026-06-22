#!/usr/bin/env bash
set -euo pipefail
DIR="${XDG_PICTURES_DIR:-$HOME/Pictures/Screenshots}"
mkdir -p "$DIR"
FILE="$DIR/Screenshot from $(date '+%Y-%m-%d %H-%M-%S').png"
niri msg action screenshot-window
sleep 0.3
LATEST=$(ls -t "$DIR" 2>/dev/null | head -1)
if [ -n "$LATEST" ] && [ -f "$DIR/$LATEST" ]; then
  wl-copy < "$DIR/$LATEST"
fi
notify-send "Captura de ecrã" "Janela guardada em Capturas"
