variable "build_number" {
  description = "ID del build de Azure DevOps para descargar de JFrog"
  type        = string
}

variable "jfrog_token" {
  description = "Token de JFrog Artifactory"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Entorno donde se despliega (DEV, PROD)"
  type        = string
}

variable "redis_endpoint" {
  description = "URL del clúster de ElastiCache"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN del rol Cross-Account en la cuenta destino"
  type        = string
}

variable "private_subnet_ids" {
  description = "Lista de subredes privadas en la VPC"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "ID del Security Group asociado a la Lambda"
  type        = string
}

variable "redis_port" {
  description = "Puerto del clúster de ElastiCache"
  type        = number
  default     = 6379
}