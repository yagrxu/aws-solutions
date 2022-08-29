provider "aws" {
  version = "~> 2.70.0"
  access_key = var.access_key_id
  secret_key = var.access_key_secret
  region     = var.region
  assume_role {
    role_arn     = var.role_arn
    session_name = "MY_TIME"
  }
}
terraform {
  backend "s3" {
    bucket         = "yagr-tf-state"
    key            = "devops-demo/cloud_services"
    region         = "eu-central-1"
    dynamodb_table = "app-state"
  }
}

data "aws_caller_identity" "current" {
  
}

locals {
  table_name          = "demo"
  counters_table_name = "counters"
}

module storage {
  source              = "../modules/storage"
  table_name          = local.table_name
  counters_table_name = local.counters_table_name
}

module backend {
  source              = "../modules/backend"
  region              = var.region
  api_url             = module.storage.graphql_url
  api_key             = module.storage.api_key
  table_name          = local.table_name
  counters_table_name = local.counters_table_name
  account_id          = data.aws_caller_identity.current.account_id
}

module frontend {
  source = "../modules/frontend"
  web_url = "blog.yagrxu.me"
  content_path = "../../s3/demo/public/"
  apigw_get_stage_id = module.backend.apigw_get_stage_id
  apigw_get_id = module.backend.apigw_get_id
}