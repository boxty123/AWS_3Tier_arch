resource "aws_subnet" "public" {
  for_each = {
    for idx, cfg in local.az_map : tostring(idx) => cfg
  }

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.pub
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-public-${each.value.az}"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = {
    for p in local.private_pairs : p.key => p
  }

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name        = "${var.project_name}-${var.environment}-private-${each.value.az}-${replace(each.key, "/.*-/", "")}"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "private"
  }
}
