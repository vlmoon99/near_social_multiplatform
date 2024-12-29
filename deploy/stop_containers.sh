#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Ensure the script is run as sudo or with superuser privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or use sudo."
  exit 1
fi

cd supabase/docker

# Stop the Contaienrs
echo "Stop Supabase Containers..."
sudo docker compose stop

