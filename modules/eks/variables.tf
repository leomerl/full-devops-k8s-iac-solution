variable "name" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.31"
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "instance_types" {
  type    = list(string)
  default = ["m5.large"]
}

variable "ami_release_version" {
  type    = string
  default = null
}

variable "remote_network_cidr" {
  type = string
}

variable "remote_pod_cidr" {
  type = string
}

variable "endpoint_public_access_cidrs" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
