#!/bin/bash
# Recreate Talos K8s VMs on Proxmox
# Run on Proxmox host: bash create-vms.sh
# Requires: nocloud-amd64.iso already uploaded to local storage

set -euo pipefail

ISO="local:iso/nocloud-amd64.iso"

echo "=== Creating talos-cp-01 (VM 100) ==="
qm create 100 \
  --name talos-cp-01 \
  --ostype l26 \
  --machine q35 \
  --cpu host \
  --sockets 1 \
  --cores 2 \
  --memory 4096 \
  --balloon 0 \
  --numa 0 \
  --agent 1 \
  --scsihw virtio-scsi-single \
  --net0 virtio,bridge=vmbr0,firewall=1 \
  --ide2 "${ISO},media=cdrom" \
  --boot order=scsi0\;ide2\;net0

qm set 100 --scsi0 local-lvm:30,iothread=1

echo "=== Creating talos-worker-01 (VM 101) ==="
qm create 101 \
  --name talos-worker-01 \
  --ostype l26 \
  --machine q35 \
  --cpu host \
  --sockets 1 \
  --cores 4 \
  --memory 8192 \
  --balloon 0 \
  --numa 0 \
  --agent 1 \
  --scsihw virtio-scsi-single \
  --net0 virtio,bridge=vmbr0,firewall=1 \
  --ide2 "${ISO},media=cdrom" \
  --boot order=scsi0\;ide2\;net0

qm set 101 --scsi0 local-lvm:60,iothread=1

echo "=== Done. Start VMs with: ==="
echo "qm start 100"
echo "qm start 101"
