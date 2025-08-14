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


module "aws_alb" {
  source       = "./modules/aws_alb"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.aws_vpc.vpc_id

  public_subnet_ids = module.aws_subnet.public_subnet_ids

  target_port       = 8080

  target_type       = "instance"

  health_check_path = "/health"
}

# (예시) 프라이빗 서브넷의 앱 인스턴스 2개가 이미 있다 가정
#  - 보안그룹/서브넷 등은 별도 모듈/리소스로 생성되어 있다고 가정
#  - 여기서는 타겟 그룹에 붙이는 예시만 보여줌
resource "aws_lb_target_group_attachment" "app_a" {
  target_group_arn = module.alb.target_group_arn
  target_id        = aws_instance.app_a.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "app_b" {
  target_group_arn = module.alb.target_group_arn
  target_id        = aws_instance.app_b.id
  port             = 8080
}

# (중요) 앱 인스턴스 SG에 ALB SG에서만 들어오도록 인바운드 열기
#  - app_sg_id는 앱 인스턴스의 보안그룹 ID
resource "aws_security_group_rule" "app_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_sg.id
  source_security_group_id = module.alb.sg_id
}


module "rt_public" {
  source       = "./modules/aws_route_table"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.aws_vpc.vpc_id

  type               = "public"
  public_subnet_ids  = module.aws_subnet.public_subnet_ids   # 예: ["subnet-aaa", "subnet-bbb"]
  igw_id             = module.aws_igw.id
}

module "rt_private" {
  source       = "./modules/aws_route_table"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.aws_vpc.vpc_id

  type = "private"
  azs  = var.azs  # ["ap-northeast-3a", "ap-northeast-3b"]

  # 모듈 출력이 아래 형태로 나오는 걸 추천: [[az0_subnet0, az0_subnet1], [az1_subnet0, az1_subnet1]]
  private_subnet_ids_by_az = module.aws_subnet.private_subnet_ids_by_az

  # NATGW(권장) 또는 NAT 인스턴스 중 하나만 사용
  nat_gateway_ids  = module.natgw.ids   # 예: ["nat-aaa", "nat-bbb"]  (azs 길이와 동일)
  # nat_instance_ids = [aws_instance.nat_a.id, aws_instance.nat_b.id]
}
