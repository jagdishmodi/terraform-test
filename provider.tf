terraform {
  backend "s3" {
    bucket       = "s3-backend-2026"
    key          = "terraform-aws/terraform.tfstate"
    region       = "ap-southeast-2"
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}

