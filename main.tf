provider "aws" {
  region = "ap-northeast-3"
}

# VPC
module "aws_vpc" {
  source       = "./modules/aws_vpc"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}

# IGW
module "aws_igw" {
  source       = "./modules/aws_igw"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.aws_vpc.vpc_id
}

# Subnets
module "aws_subnet" {
  source       = "./modules/aws_subnet"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.aws_vpc.vpc_id

  azs = ["ap-northeast-3a", "ap-northeast-3b"]

  public_subnet_cidr_blocks = [
    "10.0.0.0/24", # 3a
    "10.0.1.0/24", # 3b
  ]

  private_subnet_cidr_blocks = [
    ["10.0.2.0/24", "10.0.4.0/24"], # 3a
    ["10.0.3.0/24", "10.0.5.0/24"], # 3b
  ]
}

# EIP
module "aws_eip" {
  source       = "./modules/aws_eip"
  project_name = var.project_name
  environment  = var.environment
}

# NAT
locals {
  public_by_az = { for _, s in module.aws_subnet.public_subnets : s.az => s.id }
}

module "aws_natgw" {
  source    = "./modules/aws_natgw"
  eip_id    = module.aws_eip.allocation_id
  subnet_id = local.public_by_az[var.nat_az]  
  nat_name  = "${var.project_name}-${var.environment}-nat"
}

# Route Tables 
module "aws_rt_public" {
  source     = "./modules/aws_rt"
  type       = "public"
  vpc_id     = module.aws_vpc.vpc_id
  igw_id     = module.aws_igw.igw_id
  name       = "${var.project_name}-${var.environment}-public-rt"
  subnet_ids = { for k, s in module.aws_subnet.public_subnets : k => s.id }
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "rt_public"
  }
}

module "aws_rt_private" {
  source         = "./modules/aws_rt"
  type           = "private"
  vpc_id         = module.aws_vpc.vpc_id
  nat_gateway_id = module.aws_natgw.nat_id
  name           = "${var.project_name}-${var.environment}-private-rt"
  subnet_ids = { for k, s in module.aws_subnet.private_subnets : k => s.id }
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "rt_private"
  }
}

# Security Groups 
module "aws_sg_public" {
  source      = "./modules/aws_sg"
  name        = "${var.project_name}-${var.environment}-public-ec2-sg"
  vpc_id      = module.aws_vpc.vpc_id
  allow_http  = true
  allow_https = true
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "aws_sg_private" {
  source = "./modules/aws_sg"
  name   = "${var.project_name}-${var.environment}-private-ec2-sg"
  vpc_id = module.aws_vpc.vpc_id
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
/*
# SSM Instance Profile 
module "ssm_profile" {
  source = "./modules/aws_ssm"
  name   = "${var.project_name}-${var.environment}-ec2-ssm"
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# EC2 
module "aws_ec2_public" {
  source = "./modules/aws_ec2"

  instance_name       = "${var.project_name}-${var.environment}-web"
  instance_type       = "t2.micro"
  subnet_id           = values(module.aws_subnet.public_subnets)[0].id
  security_group_ids  = [module.aws_sg_public.id]
  associate_public_ip = true

  instance_profile = module.ssm_profile.instance_profile_name

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Role        = "ec2-public"
  }
}

module "aws_ec2_private" {
  source = "./modules/aws_ec2"

  instance_name       = "${var.project_name}-${var.environment}-app"
  instance_type       = "t2.micro"
  subnet_id           = values(module.aws_subnet.private_subnets)[0].id
  security_group_ids  = [module.aws_sg_private.id]
  associate_public_ip = false

  instance_profile = module.ssm_profile.instance_profile_name

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Role        = "ec2-private"
  }
}*/