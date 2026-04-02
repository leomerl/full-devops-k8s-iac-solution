terraform {
  backend "s3" {
    bucket = "levys-test-bucket"
    key    = "k3s/terraform.tfstate"
    region = "eu-west-1"
  }
}