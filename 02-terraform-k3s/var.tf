variable "AWS_REGION" {
  type = string
}

variable "ALLOW_IPS" {
  type = list(string)
}

variable "state_bucket_name"{
  type    = string
}

variable "cluster_name" {
  type    = string
  default = "k3s-sandbox"
}


variable "kubeconfig_path" {
  type    = string
  default = "./k3s.yaml"
}


variable "vpc_name" {
  type    = string
  default = "main-vpc"
}

variable "igw_name" {
  type    = string
  default = "main-igw"
}