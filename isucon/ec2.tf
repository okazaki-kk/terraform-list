resource "aws_instance" "isucon" {
  ami                         = "ami-0d92a4724cae6f07b"
  instance_type               = "c6i.large"
  key_name                    = "otyamura-isucon"
  subnet_id                   = aws_subnet.isucon_public_a.id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.isucon.id]

  tags = {
    Name = "otyamura-isucon"
  }
}

resource "aws_instance" "isucon-bench" {
  ami           = "ami-0582a2a7fbe79a30d"
  instance_type = "c6i.large"
  key_name      = "otyamura-isucon"
  subnet_id     = aws_subnet.isucon_public_c.id

  vpc_security_group_ids = [aws_security_group.bench.id]

  tags = {
    Name = "otyamura-isucon-bench"
  }
}
