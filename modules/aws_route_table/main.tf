locals {
  enable_public  = var.type == "public"  ? { "public"  = true } : {}
  enable_private = var.type == "private" ? { "private" = true } : {}

  # private용: AZ 인덱스 기반 구성 맵
  private_rt_cfg = {
    for idx, az in var.azs :
    tostring(idx) => {
      az               = az
      subnets          = var.private_subnet_ids_by_az[idx]       # [subnet0, subnet1]
      nat_gateway_id   = length(var.nat_gateway_ids)  == length(var.azs) ? var.nat_gateway_ids[idx]  : null
      nat_instance_id  = length(var.nat_instance_ids) == length(var.azs) ? var.nat_instance_ids[idx] : null
    }
  }

  # private용: 라우트테이블 ↔ 서브넷 연결 pair 평탄화
  private_assoc_pairs = flatten([
    for k, cfg in local.private_rt_cfg : [
      for i, sid in cfg.subnets : {
        key         = "${k}-${i}"   # 예: "0-0", "0-1", "1-0", "1-1"
        rt_key      = k
        subnet_id   = sid
      }
    ]
  ])
}

# ---------------------
# PUBLIC
# ---------------------
resource "aws_route_table" "public" {
  for_each = local.enable_public

  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-rt"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "public"
  }
}

resource "aws_route" "public_default_igw" {
  for_each = local.enable_public

  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.igw_id
}

# 퍼블릭 서브넷들에 RT 연결
resource "aws_route_table_association" "public_subnets" {
  for_each = var.type == "public" ? {
    for sid in var.public_subnet_ids : sid => sid
  } : {}

  subnet_id      = each.value
  route_table_id = aws_route_table.public["public"].id
}

# ---------------------
# PRIVATE
# ---------------------
resource "aws_route_table" "private" {
  for_each = var.type == "private" ? local.private_rt_cfg : {}

  vpc_id = var.vpc_id

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-rt-${each.key}"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
    AZ          = each.value.az
  }
}

# 기본경로 → NATGW
resource "aws_route" "private_default_via_natgw" {
  for_each = var.type == "private" ? {
    for k, v in local.private_rt_cfg : k => v if v.nat_gateway_id != null
  } : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.nat_gateway_id
}

# 기본경로 → NAT 인스턴스
resource "aws_route" "private_default_via_nat_instance" {
  for_each = var.type == "private" ? {
    for k, v in local.private_rt_cfg : k => v if v.nat_instance_id != null
  } : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = each.value.nat_instance_id
}

# 프라이빗 서브넷 ↔ RT 연결 (AZ별 RT에 2개씩 연결)
resource "aws_route_table_association" "private_subnets" {
  for_each = var.type == "private" ? {
    for p in local.private_assoc_pairs : p.key => p
  } : {}

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.private[each.value.rt_key].id
}
