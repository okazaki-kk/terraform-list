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
    from_port   = 22 # すべてのポートに対するアクセスを許可
    to_port     = 22 # すべてのポートに対するアクセスを許可
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # 同一VPC内のIP範囲を指定
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 同一VPC内のIP範囲を指定
  }
}

# ALBのセキュリティグループ
resource "aws_security_group" "alb" {
  name   = "${local.name}-alb"
  vpc_id = module.vpc.vpc_id
  ingress {
    description = "Allow HTTP from ALL."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["3.113.59.168/32", "13.113.172.248/32"]
  }
  ingress {
    description = "Allow HTTPS from ALL."
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["3.113.59.168/32", "13.113.172.248/32"]
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
