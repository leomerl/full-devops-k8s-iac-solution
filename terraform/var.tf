variable "AWS_REGION" {
  type = string
}

variable "DEFAULT_INSTANCE" {
  type = object({
    instance_type = list(string)
  })
  default = {
    instance_type = ["t3.medium"]
  }
}

variable "ALLOW_IPS" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
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

variable "capacity_type" {
  type = string
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
}