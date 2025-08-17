variable "name"         { type = string }
variable "description"{
  type=string
  default=""
}
variable "vpc_id"       { type = string }

variable "allow_http"{
  type=bool
  default=false
}

variable "allow_https"{
  type=bool
  default=false
}

variable "allow_all_ingress"{
  type=bool
  default=true
}

variable "allow_all_egress"{
  type=bool
  default=true
}


variable "additional_ingress" {
  description = "추가 인바운드 (CIDR 기반)"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    description      = optional(string)
  }))
  default = []
}

variable "additional_egress" {
  description = "추가 아웃바운드 (CIDR 기반)"
  type = list(object({
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
    description      = optional(string)
  }))
  default = []
}



variable "tags"{
  type=map(string)
  default={}
}
