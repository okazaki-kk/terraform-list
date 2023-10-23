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

resource "aws_security_group" "internal_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.default.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 同一VPC内のIP範囲を指定
  }
}
