terraform {
  backend "s3" {
    bucket = "levys-test-bucket"
    key    = "cluster-bootstrap/terraform.tfstate"
    region = "eu-west-1"
  }
}
