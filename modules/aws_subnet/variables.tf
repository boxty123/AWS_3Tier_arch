variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "azs" {
  type        = list(string)
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  type = list(list(string))
}

locals {
  
  # AZ 인덱스별 구성 묶기
  az_map = {
    for idx, az in var.azs :
    idx => {
      az   = az
      pub  = var.public_subnet_cidr_blocks[idx]
      priv = var.private_subnet_cidr_blocks[idx] 
    }
  }

  # 프라이빗 2개씩을 평탄화하여 for_each에 쓰기 좋은 구조로 변환
  private_pairs = flatten([
    for idx, cfg in local.az_map : [
      { key = "${idx}-0", az = cfg.az, cidr = cfg.priv[0] },
      { key = "${idx}-1", az = cfg.az, cidr = cfg.priv[1] },
    ]
  ])
}

