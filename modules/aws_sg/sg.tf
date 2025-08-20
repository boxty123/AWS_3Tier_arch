resource "aws_security_group" "this" {
  name        = var.name
  description = coalesce(var.description, "default_sg")
  vpc_id      = var.vpc_id
  tags        = var.tags
}

# 선택형: HTTP/HTTPS 오픈 (Anywhere)
resource "aws_security_group_rule" "ingress_http" {
  count             = var.allow_http ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.this.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP from anywhere"
}

resource "aws_security_group_rule" "ingress_https" {
  count             = var.allow_https ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.this.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS from anywhere"
}

# 모두 허용 Ingress/Egress (옵션)
resource "aws_security_group_rule" "ingress_all" {
  count             = var.allow_all_ingress ? 1 : 0
  type              = "ingress"
  security_group_id = aws_security_group.this.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All ingress"
}

resource "aws_security_group_rule" "egress_all" {
  count             = var.allow_all_egress ? 1 : 0
  type              = "egress"
  security_group_id = aws_security_group.this.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All egress"
}

# CIDR 기반 추가 인바운드
resource "aws_security_group_rule" "additional_ingress" {
  for_each = { for i, r in var.additional_ingress : i => r }

  type              = "ingress"
  security_group_id = aws_security_group.this.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks  = lookup(each.value, "ipv6_cidr_blocks", null)
  description       = lookup(each.value, "description", "additional ingress")
}

# CIDR 기반 추가 아웃바운드
resource "aws_security_group_rule" "additional_egress" {
  for_each = { for i, r in var.additional_egress : i => r }

  type              = "egress"
  security_group_id = aws_security_group.this.id
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks  = lookup(each.value, "ipv6_cidr_blocks", null)
  description       = lookup(each.value, "description", "additional egress")
}

# SG 기반 추가 인바운드 (ALB → EC2 허용 등에 필수)
resource "aws_security_group_rule" "additional_sg_ingress" {
  for_each = { for i, r in var.additional_sg_ingress : i => r }

  type                     = "ingress"
  security_group_id        = aws_security_group.this.id
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  source_security_group_id = each.value.source_security_group_id
  description              = lookup(each.value, "description", "additional sg ingress")
}
