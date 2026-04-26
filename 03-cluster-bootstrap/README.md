> *AI generated content*

# 03 - Cluster Bootstrap

Configures the K3s cluster with ArgoCD, Temporal, and supporting tools via Helm and ApplicationSets.

## What it deploys
- ArgoCD (with Traefik ingress)
- Temporal (via ArgoCD ApplicationSet)
- Reflector (secret mirroring across namespaces)
- Loki + Promtail (log aggregation)
- Prometheus + Grafana (monitoring)
- ApplicationSets from `applicationsets/` folder

## Usage
```bash
cd 03-cluster-bootstrap
terraform init
terraform plan
terraform apply
```

## Variables
| Name | Description | Default |
|------|-------------|---------|
| `AWS_REGION` | AWS region | — |
| `ALLOW_IPS` | List of allowed CIDRs | — |
| `state_bucket_name` | S3 state bucket name | — |
| `kubeconfig_path` | Path to kubeconfig | `../02-terraform-k3s/k3s.yaml` |
| `dockerhub_username` | Docker Hub username | — |
| `dockerhub_token` | Docker Hub access token | — |
| `github_token` | GitHub personal access token | — |
| `argocd_admin_password` | ArgoCD admin bcrypt hash | — |


## Docker hub token
[Personal Access Token](https://app.docker.com/accounts/<YOURID>/settings/personal-access-tokens)

## Github token
[Fine-grained personal access tokens](https://github.com/settings/personal-access-tokens)
