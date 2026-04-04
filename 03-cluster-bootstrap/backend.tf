terraform {
  backend "s3" {
    bucket = "levy-test-bucket"
    key    = "cluster-bootstrap/terraform.tfstate"
    region = "eu-west-1"
  }
}
