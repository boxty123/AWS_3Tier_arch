resource "aws_nat_gateway" "nat"{
    allocation_id = var.eip_id
    subnet_id = var.subnet_id

  tags = merge(
    {
      Name = var.nat_name
    },
    var.tags
  )
}