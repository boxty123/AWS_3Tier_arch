output "public_subnets" {
  value = {
    for k, s in aws_subnet.public :
    k => {
      id   = s.id
      cidr = s.cidr_block
      az   = s.availability_zone
    }
  }
}

output "private_subnets" {
  value = {
    for k, s in aws_subnet.private :
    k => {
      id   = s.id
      cidr = s.cidr_block
      az   = s.availability_zone
    }
  }
}
