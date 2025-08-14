variable "project_name" { type = string }
variable "environment"  { type = string }
variable "vpc_id"       { type = string }

# public | private
variable "type" {
  type        = string
  description = "Route table type: public or private"
  validation {
    condition     = contains(["public", "private"], var.type)
    error_message = "type은 public 또는 private 이어야 합니다."
  }
}

# ---------------------
# PUBLIC 모드 전용 입력
# ---------------------
variable "public_subnet_ids" {
  type        = list(string)
  description = "ALB/NLB 등 인터넷 진입이 필요한 퍼블릭 서브넷 IDs"
  default     = []
}

variable "igw_id" {
  type        = string
  description = "Internet Gateway ID (public 모드에서 필요)"
  default     = ""
}

# ---------------------
# PRIVATE 모드 전용 입력
# ---------------------
variable "azs" {
  type        = list(string)
  description = "AZ 리스트 (private 모드에서 필요)"
  default     = []
}

# 각 AZ마다 프라이빗 서브넷 2개 → list(list(string)) (예: [[subnetA0, subnetA1], [subnetB0, subnetB1]])
variable "private_subnet_ids_by_az" {
  type        = list(list(string))
  description = "AZ별 프라이빗 서브넷 ID 묶음 (각 AZ에 2개)"
  default     = []
}

# NATGW 또는 NAT 인스턴스 중 하나만 사용 (둘 다 X)
variable "nat_gateway_ids" {
  type        = list(string)
  description = "AZ별 NAT 게이트웨이 ID (private 모드 선택지 1)"
  default     = []
}

variable "nat_instance_ids" {
  type        = list(string)
  description = "AZ별 NAT 인스턴스 ID (private 모드 선택지 2)"
  default     = []
}

# ---------------------
# VALIDATIONS
# ---------------------
locals {
  _is_public = var.type == "public"
  _is_private = var.type == "private"

  _private_has_natgw  = local._is_private && length(var.nat_gateway_ids)  == length(var.azs) && length(var.nat_instance_ids) == 0
  _private_has_natins = local._is_private && length(var.nat_instance_ids) == length(var.azs) && length(var.nat_gateway_ids)  == 0
}

# public용 유효성
validation {
  condition     = !local._is_public || (length(var.public_subnet_ids) >= 1 && var.igw_id != "")
  error_message = "public 모드에서는 public_subnet_ids(>=1)와 igw_id가 필요합니다."
}

# private용 유효성
validation {
  condition = !local._is_private
    || (
      length(var.azs) == length(var.private_subnet_ids_by_az)
      && alltrue([for p in var.private_subnet_ids_by_az : length(p) == 2])   # 각 AZ에 2개
      && (local._private_has_natgw || local._private_has_natins)              # NATGW 또는 NAT 인스턴스 중 정확히 하나
    )
  error_message = "private 모드에서는 azs와 private_subnet_ids_by_az 길이가 동일하고(각 AZ에 2개), NATGW 또는 NAT 인스턴스 중 하나만 AZ 개수와 동일하게 제공해야 합니다."
}
