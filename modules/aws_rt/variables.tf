variable "type" {
  type        = string
  validation {
    condition     = contains(["public", "private"], var.type)
    error_message = "Public or Private"
  }
}


variable "vpc_id"{
    type=string
}
variable "igw_id"{
    type=string
    default=""
}
variable "nat_gateway_id"{
    type=string
    default=""
}
variable "subnet_ids"{
    type=map(string)
    default={}
}
variable "name"{
    type=string
    default="rt"
}
variable "tags"{
    type=map(string)
    default={}
}