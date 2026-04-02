#!/bin/bash
set -euo pipefail

curl -sfL https://get.k3s.io | \
  K3S_TOKEN="${k3s_token}" \
  K3S_URL="https://${server_ip}:6443" \
  INSTALL_K3S_CHANNEL="${k3s_channel}" \
  sh -s - agent
