#!/bin/bash
set -euo pipefail

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)

curl -sfL https://get.k3s.io | \
  K3S_TOKEN="${k3s_token}" \
  INSTALL_K3S_CHANNEL="${k3s_channel}" \
  sh -s - server \
    --write-kubeconfig-mode 644 \
    --tls-san "$PUBLIC_IP" \
    --tls-san "$PRIVATE_IP"
