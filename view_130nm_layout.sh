#!/bin/bash
# ==============================================================================
# 1-Click Script to Open Chip Layout in OpenROAD GUI (via OpenLane Docker)
# ==============================================================================

OPENLANE_DIR="/home/jeevan/Desktop/my projects/major project/OpenLane"
RUN_DIR="designs/lfsr_nfsr/runs/RUN_2026.03.15_14.36.07"
IMAGE_NAME="efabless/openlane:2023.09.07"

if [ ! -d "$OPENLANE_DIR" ]; then
    echo "OpenLane directory not found at $OPENLANE_DIR"
    exit 1
fi

echo "=================================================="
echo "  Launching OpenROAD GUI in OpenLane Docker...    "
echo "=================================================="
echo "Loading routed layout from: $RUN_DIR"

# Allow local X11 display connection from Docker container
xhost +local:root >/dev/null 2>&1 || xhost + >/dev/null 2>&1

# Run OpenLane GUI inside the Docker container where OpenROAD is installed
docker run --rm -it \
    --net=host \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$OPENLANE_DIR":/openlane \
    -w /openlane \
    "$IMAGE_NAME" \
    python3 gui.py "$RUN_DIR" --viewer openroad -s routing
