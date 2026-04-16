#!/usr/bin/env bash
set -euo pipefail

HOSTNAME="${1:-hm-pc-ws-01}"
DISK="${2:-/dev/nvme0n1}"

echo "Installing NixOS"
echo "  Host:   $HOSTNAME"
echo "  Disk:   $DISK"
echo ""
read -rp "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }

sudo nix --extra-experimental-features 'nix-command flakes' \
  run 'github:nix-community/disko#disko-install' -- \
  --flake "github:RedonlineOfficial/nixosConf#$HOSTNAME" \
  --disk main "$DISK" \
  --write-efi-boot-entries
