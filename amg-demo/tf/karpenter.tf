locals {
  account_id          = data.aws_caller_identity.current.account_id
  partition           = data.aws_partition.current.partition
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${var.cluster_name}"
  role = module.eks.eks_managed_node_groups["default"].iam_role_name
}


module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1"

  role_name                          = "karpenter-controller-${var.cluster_name}"

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "v0.23.0"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter_irsa.iam_role_arn
  }

  set {
    name  = "settings.aws.clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }
}

data "aws_iam_policy_document" "karpenter_controller" {

  statement {
    actions = [
      "ec2:CreateFleet",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateTags",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceTypeOfferings",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplates",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSpotPriceHistory",
      "ec2:DescribeSubnets",
      "pricing:GetProducts",
      "ec2:TerminateInstances",
      "ec2:DeleteLaunchTemplate",
    ]

    resources = ["*"]
  }


  statement {
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:${local.partition}:ec2:*:${local.account_id}:launch-template/*",
    ]
  }

  statement {
    actions = ["ec2:RunInstances"]
    resources = [
      "arn:${local.partition}:ec2:*::image/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:instance/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:spot-instances-request/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:security-group/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:volume/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:network-interface/*",
      "arn:${local.partition}:ec2:*:${local.account_id}:subnet/*",
    ]
  }

  statement {
    actions   = ["ssm:GetParameter"]
    resources = [ "arn:aws:ssm:*:*:parameter/aws/service/*" ]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = [ "*" ]
  }

}

resource "aws_iam_policy" "karpenter_controller" {

  name_prefix = "Karpenter_Controller_Policy-"
  path        = "/"
  description = "Provides permissions to handle node termination events via the Node Termination Handler"
  policy      = data.aws_iam_policy_document.karpenter_controller.json

}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {

  role       = module.karpenter_irsa.iam_role_name
  policy_arn = aws_iam_policy.karpenter_controller.arn

}

data "aws_iam_policy_document" "this" {

  statement {

    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:sub"
      values   = [for sa in ["karpenter:karpenter"] : "system:serviceaccount:${sa}"]
    }

    # https://aws.amazon.com/premiumsupport/knowledge-center/eks-troubleshoot-oidc-and-irsa/?nc1=h_ls
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_arn, "/^(.*provider/)/", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

  }
}