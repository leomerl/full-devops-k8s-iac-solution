> *AI generated content*

# 02 - Terraform K3s

Provisions a single-node K3s cluster on an EC2 instance, including VPC, networking, and SSH key pair.

## Usage
```bash
cd 02-terraform-k3s
terraform init 
terraform plan
terraform apply
export KUBECONFIG=$(pwd)/k3s.yaml
```

## Variables
| Name | Description | Default |
|------|-------------|---------|
| `AWS_REGION` | AWS region | — |
| `ALLOW_IPS` | List of allowed CIDRs | — |
| `state_bucket_name` | S3 state bucket name | — |
| `cluster_name` | K3s cluster name | `k3s-sandbox` |
| `kubeconfig_path` | Path to kubeconfig output | `./k3s.yaml` |
| `vpc_name` | VPC name | `main-vpc` |
| `igw_name` | Internet gateway name | `main-igw` |
