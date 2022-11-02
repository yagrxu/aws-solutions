terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.12.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
  }
  backend "s3" {
    bucket = "yagr-tf-state-log"
    key    = "aws-solutions/xray-demo"
    region = "us-east-1"
  }
}
