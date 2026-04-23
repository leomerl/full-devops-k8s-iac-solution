terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.AWS_REGION
  default_tags {
    tags = {
      Project     = var.project_name
      Owner   = "Eyal Levy"
      schedule = "stop_dont_start"
      Environment = var.enviorment
    }
  }
}

provider "random" {}
