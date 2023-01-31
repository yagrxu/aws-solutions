module "eks-lb-controller" {
  source  = "DNXLabs/eks-lb-controller/aws"
  version = "0.7.0"
  cluster_identity_oidc_issuer     = var.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = var.oidc_provider_arn
  cluster_name                     = var.cluster_name
}