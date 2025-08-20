
variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id"{
  type=string
}

variable "protocol" {
  type    = string
  default = "HTTP"
}

variable "port" {
  type    = number
  default = 8080
}

variable "public_subnet_ids"{
  type = map(string)
}
variable "private_subnet_ids"{
  type = map(string)
}


variable "ex_alb_sg_id"{
  type=string
}
variable "in_alb_sg_id"{
  type=string
}

variable "target_instance_map"{
  type=map(string)
  default={}
}
