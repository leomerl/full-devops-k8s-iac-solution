terraform {
  backend "s3" {
    bucket = "levys-test-bucket"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}
