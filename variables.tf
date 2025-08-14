variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-3"
}

variable "project_name" {
  description = "Name of project"
  type        = string
  default     = "AWS_3-Tier"
}

variable "environment" {
  description = "Environment Type"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC Network Range"
  type        = string
  default     = "10.0.0.0/20"
}
