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
    ["10.0.2.0/24", "10.0.4.0/24", "10.0.6.0/24"], # 3a
    ["10.0.3.0/24", "10.0.5.0/24", "10.0.7.0/24"], # 3b
  ]
}

# EIP
module "aws_eip" {
  source       = "./modules/aws_eip"
  project_name = var.project_name
  environment  = var.environment
}

# NAT
locals { public_by_az = { for _, s in module.aws_subnet.public_subnets : s.az => s.id } }

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
  allow_all_ingress=true
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "aws_sg_private" {
  source = "./modules/aws_sg"
  name   = "${var.project_name}-${var.environment}-private-ec2-sg"
  vpc_id = module.aws_vpc.vpc_id

  # ALB SG에서 들어오는 트래픽만 서비스 포트 허용
  additional_sg_ingress = [
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      source_security_group_id = module.aws_sg_ex_alb.id  # External ALB
      description              = "App port from EX-ALB"
    },
    {
      from_port                = 8080
      to_port                  = 8080
      protocol                 = "tcp"
      source_security_group_id = module.aws_sg_in_alb.id  # Internal ALB
      description              = "App port from IN-ALB"
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


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
module "aws_ec2_private" {
  source = "./modules/aws_ec2"

  for_each=module.aws_subnet.private_subnets

  instance_name = "${var.project_name}-${var.environment}-app-${each.key}"
  instance_type       = "t3.micro"
  subnet_id           = each.value.id
  security_group_ids  = [module.aws_sg_private.id]
  associate_public_ip = false

  instance_profile = module.ssm_profile.instance_profile_name

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Role        = "ec2-private"
  }
}

# EXTERNAL ALB SG: 80 오픈 
module "aws_sg_ex_alb" {
  source = "./modules/aws_sg"
  name   = "${var.project_name}-${var.environment}-ex-alb-sg"
  vpc_id = module.aws_vpc.vpc_id

  allow_http  = true
  allow_https = false

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


# EX_ALB & IN_ALB
module "aws_alb" {
  source       = "./modules/aws_alb"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.aws_vpc.vpc_id

  protocol="HTTP"
  port= 8080

  ex_alb_sg_id = module.aws_sg_ex_alb.id
  in_alb_sg_id = module.aws_sg_in_alb.id

  public_subnet_ids = { for k, s in module.aws_subnet.public_subnets  : k => s.id }
  private_subnet_ids = { for k, s in module.aws_subnet.private_subnets : k => s.id }

  target_instance_map = {
    for k, m in module.aws_ec2_private :k=> m.instance_id
  }
}


# INTERNAL ALB SG: 내부에서만 80 오픈 (VPC CIDR 기준)
module "aws_sg_in_alb" {
  source = "./modules/aws_sg"
  name   = "${var.project_name}-${var.environment}-in-alb-sg"
  vpc_id = module.aws_vpc.vpc_id

  additional_ingress = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [module.aws_vpc.vpc_cidr]
      description = "HTTP from VPC"
    }
  ]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
