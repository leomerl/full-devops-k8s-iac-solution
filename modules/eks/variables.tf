variable "name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "instance_types" {
  type = list(string)
}

variable "capacity_type" {
  type = string
  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.capacity_type)
    error_message = "capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "desired_size" {
  type    = number
  default = 2
}

variable "endpoint_private_access" {
  type    = bool
  default = true
}

variable "enable_cluster_creator_admin_permissions" {
  type    = bool
  default = true
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
