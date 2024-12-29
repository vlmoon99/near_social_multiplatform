#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run as sudo or with superuser privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

# Clone the repository with sparse checkout
echo "Cloning the supabase repository..."
git clone --filter=blob:none --no-checkout https://github.com/supabase/supabase
cd supabase
git sparse-checkout set --cone docker && git checkout master

# Navigate to the docker directory
echo "Navigating to the docker folder..."
cd docker

# Copy the example environment file
echo "Setting up the environment variables..."
cp .env.example .env

# Copy functions to the volume
SOURCE_DIR="../../../supabase/functions"
DEST_DIR="./volumes/functions"

# Add functions to the volumes from root folder
echo "Copying functions from $SOURCE_DIR to $DEST_DIR..."
mkdir -p "$DEST_DIR"
cp -r "$SOURCE_DIR"/* "$DEST_DIR"


# Pull the latest Docker images
echo "Pulling the latest Docker images..."
sudo docker compose pull

