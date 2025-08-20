variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-3"
}

variable "project_name" {
  description = "Name of project"
  type        = string
  default     = "3-Tier"
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

variable "nat_az" {
  type        = string
  description = "AZ where NAT Gateway will be placed"
  default = "ap-northeast-3a"
}

