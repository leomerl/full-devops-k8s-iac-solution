terraform {
  backend "s3" {
    bucket = "levy-test-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
