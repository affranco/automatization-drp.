terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

# 1. Descarga inmutable del artefacto desde JFrog
data "http" "lambda_zip" {
  url = "https://trialmww3an.jfrog.io/artifactory/drp-artifacts/lambda/drp-redis-flush/${var.build_number}/drp-redis-flush.zip"
  
  request_headers = {
    Authorization = "Bearer ${var.jfrog_token}"
  }
}

# 2. Almacenamiento temporal para que el AWS Provider lo lea
resource "local_file" "lambda_payload" {
  content_base64 = data.http.lambda_zip.response_body_base64
  filename       = "${path.module}/drp-redis-flush.zip"
}

# 3. Creación de la Lambda
resource "aws_lambda_function" "redis_flush" {
  filename         = local_file.lambda_payload.filename
  function_name    = "drp-redis-flush"
  role             = var.lambda_execution_role_arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256(local_file.lambda_payload.filename)
  runtime          = "python3.9"
  timeout          = 30
  
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      REDIS_ENDPOINT = var.redis_endpoint
      REDIS_PORT     = "${var.redis_port}"
      ENVIRONMENT    = var.environment
    }
  }
}