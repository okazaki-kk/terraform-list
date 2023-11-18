resource "aws_instance" "step" {
  ami                         = "ami-0d52744d6551d851e"
  instance_type               = "t2.small"
  key_name                    = "otyamura-isucon"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.step.id]

  tags = {
    Name = "${local.name}-step"
  }
}

output "step_public_ip" {
  value = aws_instance.step.public_ip
}
