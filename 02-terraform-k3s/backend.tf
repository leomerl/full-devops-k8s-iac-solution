terraform {
  backend "s3" {
    bucket = "levy-test-bucket"
    key    = "k3s/terraform.tfstate"
    region = "eu-west-1"
  }
}