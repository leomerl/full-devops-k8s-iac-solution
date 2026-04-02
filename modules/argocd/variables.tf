variable "chart_version" {
  type    = string
  default = null
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "name" {
  type    = string
  default = "argocd"
}

variable "repository" {
  type    = string
  default = "https://argoproj.github.io/argo-helm"
}

variable "chart" {
  type = string
}