resource "aws_route_table" "this"{
    vpc_id=var.vpc_id
    tags=merge(
        {
            Name=var.name
        },
        var.tags
    )
}

resource "aws_route" "default_ipv4"{
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"

  gateway_id     = var.type == "public"  ? var.igw_id         : null
  nat_gateway_id = var.type == "private" ? var.nat_gateway_id : null  
}

resource "aws_route_table_association" "subnets" {
  for_each       = toset(var.subnet_ids)
  subnet_id      = each.value
  route_table_id = aws_route_table.this.id
}