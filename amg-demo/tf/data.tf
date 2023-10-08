data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_id
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

provider "aws" {
  alias  = "sso"
  region = var.sso_region
}

data "aws_ssoadmin_instances" "example" {
  provider = aws.sso
}

data "aws_identitystore_user" "example" {
  provider          = aws.sso
  identity_store_id = tolist(data.aws_ssoadmin_instances.example.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = var.grafana_username
    }
  }
}
