terraform {
  backend "s3" {} # <-- ESTA LÍNEA ES LA CLAVE FALTANTE
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_lambda_function" "redis_flush" {
  filename         = "drp-redis-flush.zip" # Apunta directo al archivo local
  function_name    = "drp-redis-flush"
  role             = var.lambda_execution_role_arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("drp-redis-flush.zip") # Ya existirá físicamente
  runtime          = "python3.9"
  timeout          = 30
  
  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_security_group_id]
  }

  environment {
    variables = {
      REDIS_ENDPOINT = var.redis_endpoint
      REDIS_PORT     = "6379"
      ENVIRONMENT    = var.environment
    }
  }
}