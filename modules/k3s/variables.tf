variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "allowed_cidrs" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "agent_instance_type" {
  type    = string
  default = "t3.small"
}

variable "ami_id" {
  type    = string
  default = null
}

variable "k3s_channel" {
  type    = string
  default = "stable"
  validation {
    condition     = contains(["stable", "latest", "testing"], var.k3s_channel)
    error_message = "k3s_channel must be stable, latest, or testing."
  }
}

variable "create_agent" {
  type    = bool
  default = false
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "associate_public_ip_address" {
  type    = bool
  default = true
}

variable "extra_ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
