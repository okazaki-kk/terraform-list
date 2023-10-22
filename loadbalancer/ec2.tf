resource "aws_instance" "default" {
  ami                         = "ami-08a706ba5ea257141"
  instance_type               = "t2.micro"
  key_name                    = "otyamura-isucon"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  //  vpc_security_group_ids = [aws_security_group.default.id]
  tags = {
    Name = "${local.name}-default"
  }
}

resource "aws_instance" "web1" {
  ami           = "ami-08a706ba5ea257141"
  instance_type = "t2.micro"
  key_name      = "otyamura-isucon"
  subnet_id     = module.vpc.private_subnets[0]

  tags = {
    Name = "${local.name}-web1"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-08a706ba5ea257141"
  instance_type = "t2.micro"
  key_name      = "otyamura-isucon"
  subnet_id     = module.vpc.private_subnets[1]

  tags = {
    Name = "${local.name}-web2"
  }
}
