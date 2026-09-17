#!/bin/bash
# ==============================================================================
# Script to rename project directory to Grain-PRG-45
# ==============================================================================

OLD_PATH="/home/jeevan/Desktop/my projects/Design-and-ASIC-Implementation-of-Integrated-LFSR-NFSR-Based-Pseudorandom-Generator-Using-45nm-tech"
NEW_PATH="/home/jeevan/Desktop/my projects/Grain-PRG-45"

if [ -d "$OLD_PATH" ]; then
    echo "Renaming directory to Grain-PRG-45..."
    mv "$OLD_PATH" "$NEW_PATH"
    echo "Successfully renamed directory to: $NEW_PATH"
else
    echo "Directory $OLD_PATH not found or already renamed."
fi
