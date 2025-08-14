provider "aws" {
  region = "ap-northeast-3"
}

module "aws_vpc" {
  source       = "./modules/aws_vpc"
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
}


module "aws_igw" {
  source       = "./modules/aws_igw"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.aws_vpc.vpc_id
}


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

module "aws_eip"{
  source="./modules/aws_eip"
  project_name = var.project_name
  environment  = var.environment
}

module "aws_natgw" {
  source    = "./modules/aws_natgw"
  eip_id    = module.aws_eip.allocation_id
  subnet_id = values(module.aws_subnet.public_subnets)[0].id
  nat_name  = "${var.project_name}-${var.environment}-nat"
}