variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "allowed_cidrs" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
