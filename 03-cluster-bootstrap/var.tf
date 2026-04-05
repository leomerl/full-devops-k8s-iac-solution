variable "AWS_REGION" {
  type = string
}

variable "ALLOW_IPS" {
  type = list(string)
}
variable "state_bucket_name"{
  type    = string
}

variable "kubeconfig_path" {
  type    = string
  default = "../02-terraform-k3s/k3s.yaml"
}

variable "dockerhub_username" {
  type = string
}

variable "dockerhub_token" {
  type      = string
  sensitive = true
}

variable "github_token" {
  type      = string
  sensitive = true
}


variable "argocd_admin_password" {
  type      = string
  sensitive = true
}
# variable "weave_gitops_password_hash" {
#   type      = string
#   sensitive = true
# }
