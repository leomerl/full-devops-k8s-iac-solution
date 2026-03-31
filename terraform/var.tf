
variable "AWS_REGION" {
  default = "eu-west-1"
}


variable "DEFAULT_INSTANCE" {
  type = object({
    instance_type = list(string)
  })
  default = {
    instance_type = ["m5.large"]
  }
}

variable "ALLOW_IPS" {
  default = ["46.116.246.0/24"]
}

variable "cluster_name" {
  type    = string
  default = "lab-eks-cluster"
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "ami_release_version" {
  type    = string
  default = null
}

variable "remote_network_cidr" {
  type    = string
  default = "10.1.0.0/16"
}

variable "remote_pod_cidr" {
  type    = string
  default = "10.2.0.0/16"
}

variable "capacity_type" {
  type    = string
  default = "SPOT"
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
}