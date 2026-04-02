#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_apply() {
  local dir="$1"
  echo "==> terraform apply: $dir"
  cd "$REPO_ROOT/$dir"
  terraform apply -auto-approve
}

KUBECONFIG_PATH="$REPO_ROOT/terraform-k3s/k3s.yaml"

validate_cluster() {
  echo "==> validating cluster"

  if [[ ! -f "$KUBECONFIG_PATH" ]]; then
    echo "ERROR: kubeconfig not found at $KUBECONFIG_PATH"
    exit 1
  fi

  if ! kubectl --kubeconfig "$KUBECONFIG_PATH" cluster-info &>/dev/null; then
    echo "ERROR: cluster API is not reachable"
    exit 1
  fi

  if ! kubectl --kubeconfig "$KUBECONFIG_PATH" get nodes \
      -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' \
      | grep -q "True"; then
    echo "ERROR: no nodes are Ready"
    exit 1
  fi

  echo "==> cluster looks healthy"
}

run_apply "terraform-k3s"
validate_cluster
run_apply "cluster-bootstrap"
