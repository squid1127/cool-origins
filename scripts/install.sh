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
ORIGINS_MAGIC_DEST="$INSTALL_DIR/plugins/Origins-Magic/origins"
ORIGINS_FANTASY_DEST="$INSTALL_DIR/plugins/Origins-Fantasy/origins"
SKRIPT_DEST="$INSTALL_DIR/plugins/Skript/scripts/origins"
SKRIPT_PARENT="$INSTALL_DIR/plugins/Skript/scripts"
ABILITY_CONFIG_DEST="$INSTALL_DIR/plugins/Origins-Reborn/ability-config.yml"

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
ORIGINS_MAGIC_SRC="$PROJECT_DIR/src/origins-magic"
ORIGINS_FANTASY_SRC="$PROJECT_DIR/src/origins-fantasy"
SKRIPT_SRC="$PROJECT_DIR/src/skript"
ABILITY_CONFIG_SRC="$PROJECT_DIR/src/ability-config.yml"

# Copy origins files
echo "Copying origins files to $ORIGINS_DEST..."
cp -f "$ORIGINS_SRC"/*.json "$ORIGINS_DEST/" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Origins files copied successfully"
else
    echo "✗ Failed to copy origins files"
    exit 1
fi

# Copy origins-magic files
if [ -d "$ORIGINS_MAGIC_SRC" ]; then
    echo "Copying origins-magic files to $ORIGINS_MAGIC_DEST..."
    cp -f "$ORIGINS_MAGIC_SRC"/*.json "$ORIGINS_MAGIC_DEST/" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Origins-magic files copied successfully"
    else
        echo "✗ Failed to copy origins-magic files"
        exit 1
    fi
fi

# Copy origins-fantasy files
if [ -d "$ORIGINS_FANTASY_SRC" ]; then
    echo "Copying origins-fantasy files to $ORIGINS_FANTASY_DEST..."
    cp -f "$ORIGINS_FANTASY_SRC"/*.json "$ORIGINS_FANTASY_DEST/" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✓ Origins-fantasy files copied successfully"
    else
        echo "✗ Failed to copy origins-fantasy files"
        exit 1
    fi
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

# Ask about ability-config.yml
if [ -f "$ABILITY_CONFIG_SRC" ]; then
    echo ""
    read -p "Do you want to override ability-config.yml? (recommended) [Y/n]: " RESPONSE
    RESPONSE=${RESPONSE:-Y}  # Default to Y if empty
    
    if [[ "$RESPONSE" =~ ^[Yy]$ ]]; then
        echo "Copying ability-config.yml to $ABILITY_CONFIG_DEST..."
        cp -f "$ABILITY_CONFIG_SRC" "$ABILITY_CONFIG_DEST" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "✓ ability-config.yml copied successfully"
        else
            echo "✗ Failed to copy ability-config.yml"
            exit 1
        fi
    else
        echo "Skipping ability-config.yml"
    fi
fi

echo ""
echo "Installation completed successfully!"
echo "Origins installed to: $ORIGINS_DEST"
echo "Origins-magic installed to: $ORIGINS_MAGIC_DEST"
echo "Origins-fantasy installed to: $ORIGINS_FANTASY_DEST"
echo "Skripts installed to: $SKRIPT_DEST"
