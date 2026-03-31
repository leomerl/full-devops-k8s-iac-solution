terraform {
  backend "s3" {
    bucket = "levy-test-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}