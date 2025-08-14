variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "ALB가 올라갈 퍼블릭 서브넷 ID들(최소 2개, 서로 다른 AZ)"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "public_subnet_ids는 최소 2개가 필요합니다."
  }
}

variable "target_port" {
  description = "백엔드 앱 리슨 포트"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "Target group type: instance | ip"
  type        = string
  default     = "instance"
  validation {
    condition     = contains(["instance", "ip"], var.target_type)
    error_message = "target_type은 instance 또는 ip만 가능합니다."
  }
}

variable "health_check_path" {
  description = "ALB Health check path (HTTP)"
  type        = string
  default     = "/"
}
