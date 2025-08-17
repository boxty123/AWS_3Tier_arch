resource "aws_lb" "ex_lb"{
    name ="${var.project_name}-${var.environment}-ex-alb"
    load_balancer_type = "application"
    internal = false
    security_groups = [aws_security_group.ex_alb.id]
    subnets = [
        module.aws_subnet.public_subnets["ap-northeast-3a"].id,
        module.aws_subnet.public_subnets["ap-northeast-3b"].id,
    ]
}

resource "aws_lb" "in_lb"{
    name = "${var.project_name}-${var.environment}-in-alb"
    load_balancer_type= "application"
    internal = true
    security_groups = [aws_security_group.in_alb.id]
    subnets = [
        module.aws_subnet.private_subnets["ap-northeast-3a"].id,
        module.aws_subnet.private_subnets["ap-northeast-3b"].id,
    ]
}