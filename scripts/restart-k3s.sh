#!/bin/bash
set -euo pipefail

SCRIPT_DIR="./02-terraform-k3s"
PEM_FILE="$SCRIPT_DIR/my-k3s.pem"
SERVER_IP_FILE="$SCRIPT_DIR/../ServerIP.txt"

if [ ! -f "$SERVER_IP_FILE" ]; then
  echo "ERROR: ServerIP.txt not found at $SERVER_IP_FILE"
  exit 1
fi

NEW_IP=$(cat "$SERVER_IP_FILE")

echo "==========================================="
echo "=      Regenerate k3s TLS certs for       ="
echo "=         new IP: $NEW_IP                 ="
echo "==========================================="

echo "= Waiting for TLS cert file to exist..."
until ssh -i "$PEM_FILE" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=5 \
  ec2-user@$NEW_IP \
  'sudo test -f /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.crt' 2>/dev/null; do
  sleep 10
done

ssh -i "$PEM_FILE" \
  -o StrictHostKeyChecking=no \
  ec2-user@$NEW_IP \
  'sudo rm -f /var/lib/rancher/k3s/server/tls/dynamic-cert.json /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.crt /var/lib/rancher/k3s/server/tls/serving-kube-apiserver.key && sudo systemctl restart k3s'

echo "= Waiting for k3s to be ready with new certs..."
until ssh -i "$PEM_FILE" \
  -o StrictHostKeyChecking=no \
  -o ConnectTimeout=5 \
  ec2-user@$NEW_IP \
  'kubectl get nodes --kubeconfig /etc/rancher/k3s/k3s.yaml 2>/dev/null | grep -q Ready' 2>/dev/null; do
  sleep 10
done

echo "= Pulling kubeconfig to local machine..."
ssh -i "$PEM_FILE" \
  -o StrictHostKeyChecking=no \
  ec2-user@$NEW_IP \
  'cat /etc/rancher/k3s/k3s.yaml' | \
  sed "s/127.0.0.1/$NEW_IP/g" > "$SCRIPT_DIR/k3s.yaml"

echo "= Done. kubeconfig saved to $SCRIPT_DIR/k3s.yaml"
