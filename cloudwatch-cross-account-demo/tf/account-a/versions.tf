terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.50.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }
  }
  backend "s3" {
    bucket = "yagr-tf-state-log"
    key    = "workshop/observability/cloudwatch/cross-account-demo-a"
    region = "us-east-1"
    profile = "global"
  }
}