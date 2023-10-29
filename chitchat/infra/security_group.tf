resource "aws_security_group" "step" {
  name                   = "${local.name}-step"
  vpc_id                 = module.vpc.vpc_id
  revoke_rules_on_delete = false
  description            = "security group for a step server"
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

resource "aws_security_group" "db" {
  name        = "${local.name}-db"
  vpc_id      = module.vpc.vpc_id
  description = "DB security group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.step.id]
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
