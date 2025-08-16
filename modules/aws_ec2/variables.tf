variable "instance_name" {
  type        = string
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  type        = string
  default=""
}

variable "security_group_ids" {
  type        = list(string)
  description = "연결할 보안그룹 ID 목록"
  default     = []
}

variable "associate_public_ip" {
  type        = bool
  description = "퍼블릭 IP 연결 여부"
  default     = false
}

variable "instance_profile" {
  type        = string
  description = "IAM Instance Profile 이름"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "공통 태그"
  default     = {}
}
