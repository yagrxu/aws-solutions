provider "aws" {
  region = local.region
}

provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "grafana" {
  url  = try(var.grafana_endpoint, "https://${module.managed_grafana.workspace_endpoint}")
  auth = var.grafana_api_key
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

locals {
  name = var.cluster_name
  # name = basename(path.cwd)
  # var.cluster_name is for Terratest
  # cluster_name = coalesce(var.cluster_name, local.name)
  cluster_name = var.cluster_name
  region       = var.region

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
  }
}

#---------------------------------------------------------------
# Foundation for the deployment
#---------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  # Manage so we can name
  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }

  tags = local.tags
}


#---------------------------------------------------------------
# EKS Blueprints
#---------------------------------------------------------------

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints"

  cluster_name    = local.cluster_name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  managed_node_groups = {
    mg_5 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.large"]
      min_size        = 2
      max_size        = 5
      desired_size    = 2
      subnet_ids      = module.vpc.private_subnets
    }
  }

  tags = local.tags
}

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints/modules/kubernetes-addons"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Managed Add-ons
  enable_amazon_eks_vpc_cni            = true
  enable_amazon_eks_coredns            = true
  enable_amazon_eks_kube_proxy         = true
  enable_amazon_eks_aws_ebs_csi_driver = true

  # Add-ons
  enable_aws_load_balancer_controller = true
  enable_metrics_server               = true
  enable_aws_cloudwatch_metrics       = true
  enable_kubecost                     = true
  enable_gatekeeper                   = true

#   enable_cluster_autoscaler = true
#   cluster_autoscaler_helm_config = {
#     set = [
#       {
#         name  = "podLabels.prometheus\\.io/scrape",
#         value = "true",
#         type  = "string",
#       }
#     ]
#   }
  enable_aws_for_fluentbit = true
  # aws_for_fluentbit_irsa_policies = ["IAM Policies"] # Add list of additional policies to IRSA to enable access to Kinesis, OpenSearch etc.
  aws_for_fluentbit_cw_log_group_retention = 90
  aws_for_fluentbit_helm_config = {
    name                                      = "aws-for-fluent-bit"
    chart                                     = "aws-for-fluent-bit"
    repository                                = "https://aws.github.io/eks-charts"
    version                                   = "0.1.0"
    namespace                                 = "logging"
    aws_for_fluent_bit_cw_log_group           = "/${module.eks_blueprints.eks_cluster_id}/worker-fluentbit-logs" # Optional
    create_namespace                          = true
    values = [templatefile("./helm_values/aws-for-fluentbit-values.yaml", {
      region                          = data.aws_region.current.name,
      aws_for_fluent_bit_cw_log_group = "/${module.eks_blueprints.eks_cluster_id}/worker-fluentbit-logs"
    })]
    set = [
      {
        name  = "nodeSelector.kubernetes\\.io/os"
        value = "linux"
      }
    ]
  }

  # enable_argocd = true
  # argocd_helm_config = {
  #   set_sensitive = [
  #     {
  #       name  = "configs.secret.argocdServerAdminPassword"
  #       value = bcrypt(data.aws_secretsmanager_secret_version.admin_password_version.secret_string)
  #     }
  #   ]
  # }

  # observability
  # enable_amazon_eks_adot = true
  # enable_adot_collector_java = true

  # amazon_prometheus_workspace_endpoint = module.managed_prometheus.workspace_prometheus_endpoint
  # amazon_prometheus_workspace_region   = local.region

  enable_cert_manager = true
  cert_manager_helm_config = {
    set_values = [
      {
        name  = "extraArgs[0]"
        value = "--enable-certificate-owner-ref=false"
      },
    ]
  }
  # TODO - requires dependency on `cert-manager` for namespace
  # enable_cert_manager_csi_driver = true

  tags = local.tags
}

# # password for argoCD
# resource "random_password" "argocd" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# #tfsec:ignore:aws-ssm-secret-use-customer-key
# resource "aws_secretsmanager_secret" "arogcd" {
#   name                    = "argocd"
#   recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
# }

# resource "aws_secretsmanager_secret_version" "arogcd" {
#   secret_id     = aws_secretsmanager_secret.arogcd.id
#   secret_string = random_password.argocd.result
# }

# data "aws_secretsmanager_secret_version" "admin_password_version" {
#   secret_id = aws_secretsmanager_secret.arogcd.id

#   depends_on = [aws_secretsmanager_secret_version.arogcd]
# }
