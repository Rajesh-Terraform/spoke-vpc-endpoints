locals {
  interface_endpoints = toset([
    "ssm",
    "ssmmessages",
    "ec2messages",
    "logs",
    "secretsmanager",
    "kms",
    "sts",
    "ecr.api",
    "ecr.dkr"
  ])

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
} 
