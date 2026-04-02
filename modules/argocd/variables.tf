variable "cluster_endpoint" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}

variable "cluster_name" {
  type= string
}

variable "chart_version" {
  type = string
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