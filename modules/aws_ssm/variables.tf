variable "name" {
  type        = string
  description = "IAM Role/Instance Profile의 베이스 이름"
}

variable "path" {
  type        = string
  description = "IAM Role Path (조직 규칙에 맞춰 '/')"
  default     = "/"
}

variable "permissions_boundary" {
  type        = string
  description = "Permission Boundary ARN"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "공통 태그"
  default     = {}
}
