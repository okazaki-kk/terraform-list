module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.17.4"

  cluster_name    = local.name
  cluster_version = "1.28"

  create_iam_role = false
  iam_role_arn    = aws_iam_role.cluster-role.arn

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["13.113.172.248/32"]

  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = [module.vpc.public_subnets[0], module.vpc.public_subnets[1]]

  eks_managed_node_groups = {
    default_node_group = {
      min_size                              = 2
      max_size                              = 2
      desired_size                          = 2
      create_iam_role                       = false
      iam_role_arn                          = aws_iam_role.node-role.arn
      ami_type                              = "AL2_x86_64"
      instance_types                        = ["t3.large"]
      attach_cluster_primary_security_group = true
      vpc_security_group_ids                = [aws_security_group.node-additional-sg.id] # NodeについているSG
      default_node_group = {
        use_custom_launch_template = false
        disk_size                  = 50
        remote_access = {
          ec2_ssh_key = "cicd-test"
        }
      }
    }
  }
}

# IAM
resource "aws_iam_role" "cluster-role" {
  name = "eks-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "eks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "node-role" {
  name = "eks-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
            "ec2.amazonaws.com",
            "eks.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "node-AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.node-role.name
}

resource "aws_iam_role_policy_attachment" "cluster-AdministratorAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.cluster-role.name
}

resource "aws_security_group" "node-additional-sg" {
  name        = "node-allow-from-alb"
  description = "sg for nodes to allow access from the alb"
  vpc_id      = module.vpc.vpc_id

  ingress {
    cidr_blocks      = [module.vpc.vpc_cidr_block]
    description      = "eks master"
    from_port        = 30000 // nodeのServiceで定義されているportのみを許可
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = [module.eks.cluster_security_group_id]
    self             = false
    to_port          = 30000
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
    description = ""
  }
}
