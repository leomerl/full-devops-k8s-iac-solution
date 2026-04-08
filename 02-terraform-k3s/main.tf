locals {
  vpc_name          = "${var.project_name}-vpc"
  igw_name          = "${var.project_name}-igw"
  state_bucket_name = "${var.project_name}-test-bucket"
}