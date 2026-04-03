variable "kubeconfig_path" {
  type    = string
  default = "../terraform-k3s/k3s.yaml"
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

variable "weave_gitops_password_hash" {
  type      = string
  sensitive = true
}
