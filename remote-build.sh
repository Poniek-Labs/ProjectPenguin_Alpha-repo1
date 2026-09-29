#!/bin/bash
set -e

echo "=== Canerix CORE Remote Build Runner ==="

# Check for root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run with sudo or as root."
  exit 1
fi

# Ensure live-build is installed
if ! command -v lb &> /dev/null; then
    echo "Installing live-build..."
    apt-get update && apt-get install -y live-build git
fi

# Clean and Build
lb clean --purge
lb config \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --distribution trixie \
  --archive-areas "main contrib non-free-firmware" \
  --debian-installer live \
  --debian-installer-gui false \
  --bootappend-install "file=/cdrom/install/preseed.cfg auto=true priority=critical"

lb build

if [ -f "live-image-amd64.hybrid.iso" ]; then
    mv live-image-amd64.hybrid.iso Canerix-CORE-Alpha1-Trixie-amd64.iso
    sha256sum Canerix-CORE-Alpha1-Trixie-amd64.iso > Canerix-CORE-Alpha1-Trixie-amd64.iso.sha256
    echo "Build succeeded: Canerix-CORE-Alpha1-Trixie-amd64.iso"
fi
