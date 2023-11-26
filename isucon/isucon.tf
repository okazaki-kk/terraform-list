resource "aws_vpc" "isucon" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "isucon VPC"
  }
}

resource "aws_subnet" "isucon_public_a" {
  vpc_id                  = aws_vpc.isucon.id
  cidr_block              = "172.31.0.0/20"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "isucon Public a"
  }
}

resource "aws_subnet" "isucon_public_c" {
  vpc_id                  = aws_vpc.isucon.id
  cidr_block              = "172.31.16.0/20"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "isucon Public c"
  }
}

resource "aws_subnet" "isucon_public_d" {
  vpc_id            = aws_vpc.isucon.id
  cidr_block        = "172.31.32.0/20"
  availability_zone = "ap-northeast-1d"

  map_public_ip_on_launch = true

  tags = {
    Name = "isucon Public d"
  }
}

resource "aws_internet_gateway" "isucon_igw" {
  vpc_id = aws_vpc.isucon.id
  tags = {
    Name = "isucon IGW"
  }
}

resource "aws_route_table" "isucon_public" {
  vpc_id = aws_vpc.isucon.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.isucon_igw.id
  }

  tags = {
    Name = "isucon Public"
  }
}

resource "aws_route_table_association" "isucon_public_a" {
  subnet_id      = aws_subnet.isucon_public_a.id
  route_table_id = aws_route_table.isucon_public.id
}

resource "aws_route_table_association" "isucon_public_c" {
  subnet_id      = aws_subnet.isucon_public_c.id
  route_table_id = aws_route_table.isucon_public.id
}

resource "aws_route_table_association" "isucon_public_d" {
  subnet_id      = aws_subnet.isucon_public_d.id
  route_table_id = aws_route_table.isucon_public.id
}

# NOTE. https://ip-ranges.amazonaws.com/ip-ranges.json で公開されているAWSのCIDRをTerraformから取得する
data "aws_ip_ranges" "ec2_instance_connect" {
  regions  = ["ap-northeast-1"]
  services = ["ec2_instance_connect"]
}

resource "aws_security_group" "isucon" {
  vpc_id      = aws_vpc.isucon.id
  name        = "isucon"
  description = "isucon"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.113.59.168/32", "13.113.172.248/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["3.113.59.168/32", "13.113.172.248/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["3.113.59.168/32", "13.113.172.248/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "isucon"
  }
}

resource "aws_security_group" "bench" {
  vpc_id      = aws_vpc.isucon.id
  name        = "bench"
  description = "bench"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["3.113.59.168/32", "13.113.172.248/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "isucon_from_bench" {
  description              = "Allow all from Security Group for bench."
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.bench.id
  security_group_id        = aws_security_group.isucon.id
}
