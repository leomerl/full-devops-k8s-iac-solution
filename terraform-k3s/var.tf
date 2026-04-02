variable "AWS_REGION" {
  type = string
}

variable "ALLOW_IPS" {
  type = list(string)
}

variable "cluster_name" {
  type    = string
  default = "k3s-sandbox"
}
