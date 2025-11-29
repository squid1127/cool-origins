#!/bin/bash

# Install script for cool-origins project
# Usage: ./install.sh <install_directory>

# Check if install directory argument is provided
if [ -z "$1" ]; then
    echo "Error: No install directory specified"
    echo "Usage: $0 <install_directory>"
    exit 1
fi

INSTALL_DIR="$1"

# Define destination directories
ORIGINS_DEST="$INSTALL_DIR/plugins/Origins-Reborn/origins"
SKRIPT_DEST="$INSTALL_DIR/plugins/Skript/scripts/origins"
SKRIPT_PARENT="$INSTALL_DIR/plugins/Skript/scripts"

# Check if destination directories exist
if [ ! -d "$ORIGINS_DEST" ]; then
    echo "Error: Destination directory does not exist: $ORIGINS_DEST"
    exit 1
fi

# Check if Skript destination exists, create if parent exists
if [ ! -d "$SKRIPT_DEST" ]; then
    if [ -d "$SKRIPT_PARENT" ]; then
        echo "Creating Skript origins directory: $SKRIPT_DEST"
        mkdir -p "$SKRIPT_DEST"
    else
        echo "Error: Destination directory does not exist: $SKRIPT_DEST"
        exit 1
    fi
fi

# Get the script's directory to find source files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Define source directories
ORIGINS_SRC="$PROJECT_DIR/src/origins"
SKRIPT_SRC="$PROJECT_DIR/src/skript"

# Copy origins files
echo "Copying origins files to $ORIGINS_DEST..."
cp -f "$ORIGINS_SRC"/*.json "$ORIGINS_DEST/" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Origins files copied successfully"
else
    echo "✗ Failed to copy origins files"
    exit 1
fi

# Copy skript files
echo "Copying skript files to $SKRIPT_DEST..."
cp -f "$SKRIPT_SRC"/*.sk "$SKRIPT_DEST/" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Skript files copied successfully"
else
    echo "✗ Failed to copy skript files"
    exit 1
fi

echo ""
echo "Installation completed successfully!"
echo "Origins installed to: $ORIGINS_DEST"
echo "Skripts installed to: $SKRIPT_DEST"
