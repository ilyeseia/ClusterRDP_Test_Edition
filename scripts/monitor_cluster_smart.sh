#!/bin/bash
set -e

echo "🔍 Starting Smart Cluster Monitoring..."

while true; do
  echo "💡 Checking VMs status at $(date)..."

  for VM in $(docker ps -a --format '{{.Names}}' | grep RDP-VM || true); do
    if [ "$(docker inspect -f '{{.State.Running}}' $VM)" != "true" ]; then
      echo "⚠️ $VM is down! Recreating..."
      docker rm -f $VM
      ./scripts/create_rdp_vm_smart.sh
    else
      echo "✅ $VM is healthy."
    fi
  done

  sleep 300  # check every 5 minutes
done
