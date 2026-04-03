#!/usr/bin/env bash
set -eo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/.env"

KUBECONFIG="$REPO_ROOT/terraform-k3s/k3s.yaml"
KCTL="kubectl --kubeconfig $KUBECONFIG"

echo "==> kustomizations and helmreleases"
$KCTL get kustomization,helmrelease -A

echo ""
echo "==> checking for failures"
FAILED=$($KCTL get kustomization,helmrelease -A -o json \
  | jq -r '.items[] | select(.status.conditions[]? | .type == "Ready" and .status != "True") | "\(.kind)/\(.metadata.namespace)/\(.metadata.name): \(.status.conditions[]? | select(.type == "Ready") | .message)"')

if [[ -z "$FAILED" ]]; then
  echo "all healthy"
else
  echo "$FAILED"
  exit 1
fi
