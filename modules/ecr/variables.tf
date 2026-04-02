variable "name" {
  type = string
}

variable "image_tag_mutability" {
  type = string
  default = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  type = bool
  default = true
}