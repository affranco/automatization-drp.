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

variable "enable_canada_drp" {
  description = "Flag: true para desplegar orquestador en ca-central-1, false para us-east-1"
  type        = bool
  default     = false
}
