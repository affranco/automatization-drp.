terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  target_region = "us-east-1"
}

provider "aws" {
  region = local.target_region
}