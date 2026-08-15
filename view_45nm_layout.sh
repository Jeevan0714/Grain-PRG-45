#!/bin/bash
# ==============================================================================
# 1-Click Script to Open 45nm Chip Layout in OpenROAD GUI
# ==============================================================================

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

IMAGE_NAME="efabless/openlane:2023.09.07"
DEF_FILE="flow_45nm_128bit/results/lfsr_nfsr_top_45nm.def"
GUI_TCL="flow_45nm_128bit/load_45nm_gui.tcl"

if [ ! -f "$DEF_FILE" ]; then
    echo "45nm DEF layout file not found. Run openroad_pnr_128bit.tcl first!"
    exit 1
fi

echo "=================================================="
echo "  Launching NanGate 45nm Chip in OpenROAD GUI...  "
echo "=================================================="
echo "Loading 45nm layout: $DEF_FILE"

# Allow local X11 display connection from Docker container
xhost +local:root >/dev/null 2>&1 || xhost + >/dev/null 2>&1

# Launch OpenROAD GUI inside Docker with the 45nm NanGate layout
docker run --rm -it \
    --net=host \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$SCRIPT_DIR":/work \
    -v "/home/jeevan/vlsi_libraries":/home/jeevan/vlsi_libraries \
    -w /work \
    "$IMAGE_NAME" \
    openroad -gui "$GUI_TCL"
