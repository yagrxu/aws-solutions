module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name = var.cluster_name
  cidr = "192.168.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  # 对于使用karpenter做资源管理的集群来说，需要给资源所在的子网打tag来进行识别。
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery" = var.cluster_name
  }
}

resource "aws_ram_resource_share_accepter" "receiver_accept" {
  share_arn = var.resource_share_arn
}

resource "aws_ec2_transit_gateway_vpc_attachment" "example" {
  depends_on = [
    aws_ram_resource_share_accepter.receiver_accept
  ]
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.vpc.vpc_id

  tags = {
    Name = "terraform-example"
    Side = "Creator"
  }
}


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.3"

  cluster_version = "1.23"
  cluster_name    = var.cluster_name
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  enable_irsa     = true

  cluster_addons = {
    # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  # Only need one node to get Karpenter up and running
  eks_managed_node_groups = {
    default = {
      desired_size = 3
      iam_role_additional_policies = ["arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
      instance_types = ["t3.large"]
      tags = {
        Owner = "default"
      }
      security_group_rules = {
        ingress_self_all = {
          description = "Node to node all ports/protocols"
          protocol    = "-1"
          from_port   = 0
          to_port     = 0
          type        = "ingress"
          cidr_blocks = ["0.0.0.0/0"]
        }
        egress_all = {
          description      = "Node all egress"
          protocol         = "-1"
          from_port        = 0
          to_port          = 0
          type             = "egress"
          cidr_blocks      = ["0.0.0.0/0"]
        }
      }
    }
  }

  cluster_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  }

  tags = {
    "karpenter.sh/discovery" = var.cluster_name
  }
}


module "observability" {
  source                  = "../modules/observability"
  adot_namespace          = "opentelemetry-operator-system"
  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  depends_on = [
      module.eks
  ]
}

# module "eks_addon" {
#   source                  = "../modules/eks_addon"
  
# }

resource "aws_ecr_repository" "x-ray-hello" {
  name                 = "x-ray-hello-demo"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = false
  }
}