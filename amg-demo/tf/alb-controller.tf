module "eks-lb-controller" {
  source  = "DNXLabs/eks-lb-controller/aws"
  version = "0.7.0"
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = module.eks.cluster_id
  helm_chart_version               = "1.4.7"
}