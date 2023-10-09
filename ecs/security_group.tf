# ALBのセキュリティグループ
resource "aws_security_group" "alb" {
  name   = "${local.name}-alb"
  vpc_id = module.vpc.vpc_id
  ingress {
    description = "Allow HTTP from ALL."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTPS from ALL."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all to outbound."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.name}-alb"
  }
}

# ECSのセキュリティグループ
resource "aws_security_group" "ecs" {
  name   = "${local.name}-ecs"
  vpc_id = module.vpc.vpc_id
  egress {
    description = "Allow all to outbound."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.name}-ecs"
  }
}

# ECSのセキュリティグループでALBからのアクセスを許可
resource "aws_security_group_rule" "ecs_from_alb" {
  # TODO: ポート限定する
  description              = "Allow all from Security Group for ALB."
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs.id
}


resource "aws_security_group" "default" {
  name                   = "${local.name}-default"
  vpc_id                 = module.vpc.vpc_id
  revoke_rules_on_delete = false
  description            = "security group for default"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.113.59.168/32", "13.113.172.248/32"]
  }
}
