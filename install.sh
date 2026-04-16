#!/usr/bin/env bash
set -euo pipefail

HOSTNAME="${1:-hm-pc-ws-01}"

echo "Installing NixOS"
echo "  Host:   $HOSTNAME"
echo ""
read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

echo "--- Step 1: Partitioning and formatting disk ---"
sudo nix --extra-experimental-features 'nix-command flakes' \
  run 'github:nix-community/disko#disko' -- \
  --flake "github:RedonlineOfficial/nixosConf#$HOSTNAME" \
  --mode destroy,format,mount

echo "--- Step 2: Mounting target disk as nix store overlay ---"
mkdir -p /mnt/nix-store-tmp
sudo mount --bind /mnt/nix-store-tmp /nix/.rw-store

echo "--- Step 3: Installing NixOS ---"
sudo nixos-install \
  --flake "github:RedonlineOfficial/nixosConf#$HOSTNAME" \
  --no-root-passwd \
  --write-efi-boot-entries

echo "--- Step 4: Cleaning up overlay directory ---"
rm -rf /mnt/nix-store-tmp

echo "Done. You can now reboot."
