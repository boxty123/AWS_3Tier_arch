variable "eip_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "nat_name" {
  type = string
  default = "public Nat"
}

variable "tags" {
  type        = map(string)
  default     = {}
}