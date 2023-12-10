module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.2.0"

  name = local.name
  cidr = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  public_subnets  = ["10.0.11.0/24", "10.0.12.0/24"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  public_subnet_names  = ["${local.name}-public-1a", "${local.name}-public-1c"]
  private_subnet_names = ["${local.name}-private-1a", "${local.name}-private-1c"]

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway      = true
  map_public_ip_on_launch = true
}
