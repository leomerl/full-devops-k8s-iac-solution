terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
    insecure    = true
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
  insecure    = true
}
