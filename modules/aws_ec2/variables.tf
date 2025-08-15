variable "instance_name" {
  type        = string
}

variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  type        = string
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
}

variable "associate_public_ip" {
  type        = bool
  description = "퍼블릭 IP 연결 여부"
  default     = false
}

variable "instance_profile" {
  type        = string
  description = "IAM Instance Profile 이름 (SSM 등)"
  default     = ""
}

variable "tags" {
  type        = string
  default     = ""
}
