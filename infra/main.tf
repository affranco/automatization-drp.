  data "aws_vpc" "selected" {
  default = true
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.selected.id
  name   = "default"
}
  
  terraform {
  backend "s3" {} # <-- ESTA LÍNEA ES LA CLAVE FALTANTE
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.enable_canada_drp ? "ca-central-1" : "us-east-1"
}

resource "aws_lambda_function" "redis_flush" {
  filename         = "drp-redis-flush.zip"
  function_name    = "drp-redis-flush"
  role             = var.lambda_execution_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("drp-redis-flush.zip")

  vpc_config {
    subnet_ids         = data.aws_subnets.private.ids
    security_group_ids = [data.aws_security_group.default.id]
  }

  environment {
    variables = {
      REDIS_ENDPOINT = var.redis_endpoint
      ENVIRONMENT    = var.environment
    }
  }
}