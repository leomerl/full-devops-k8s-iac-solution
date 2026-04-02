variable "AWS_REGION" {
  type = string
}

variable "ALLOW_IPS" {
  type = list(string)
}

variable "KEY_NAME" {
  type = string
}

variable "VPC_ID" {
  type = string
}

variable "SUBNET_ID" {
  type = string
}

variable "cluster_name" {
  type    = string
  default = "k3s-sandbox"
}
