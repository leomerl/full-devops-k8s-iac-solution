#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

run_apply() {
  local dir="$1"
  echo "==> terraform apply: $dir"
  cd "$REPO_ROOT/$dir"
  terraform apply -auto-approve
}

KUBECONFIG_PATH="${REPO_ROOT}/terraform-k3s/k3s.yaml"

validate_tfvars() {
  local dir="$REPO_ROOT/$1"
  local example="$dir/terraform.tfvars.example"
  local tfvars="$dir/terraform.tfvars"

  echo "==> validating tfvars: $1"

  if [[ ! -f "$tfvars" ]]; then
    echo "ERROR: $tfvars not found"
    exit 1
  fi

  while IFS= read -r key; do
    if ! grep -qE "^\s*${key}\s*=" "$tfvars"; then
      echo "ERROR: missing key '$key' in $tfvars"
      exit 1
    fi
  done < <(grep -E '^\s*\w+\s*=' "$example" | sed 's/\s*=.*//' | tr -d ' ')
}

kube_wait() {
  local label="$1"
  local namespace="$2"
  local resource="$3"
  shift 3

  if ! kubectl --kubeconfig "$KUBECONFIG_PATH" wait --for=condition=Ready "$resource" -n "$namespace" "$@"; then
    echo "ERROR: $label. Diagnostics:"
    kubectl --kubeconfig "$KUBECONFIG_PATH" get "$resource" -n "$namespace" 2>/dev/null || true
    kubectl --kubeconfig "$KUBECONFIG_PATH" describe "$resource" -n "$namespace" 2>/dev/null || true
    exit 1
  fi
}

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

validate_bootstrap() {
  echo "==> validating bootstrap"

  kube_wait "flux pods not ready"          "flux-system" "pods"                          --all --timeout=120s
  kube_wait "gitrepository not ready"      "flux-system" "gitrepository/flux-system"           --timeout=120s
  kube_wait "kustomization not ready"      "flux-system" "kustomization/flux-system"           --timeout=120s

  echo "==> bootstrap looks healthy"
}

validate_tfvars "terraform-k3s"
validate_tfvars "cluster-bootstrap"
run_apply "terraform-k3s"
validate_cluster
run_apply "cluster-bootstrap"
validate_bootstrap
