terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.52.0"
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
    bucket = "yagr-tfstate-log-us"
    key    = "tfc/observability/grafana-demo"
    region = "us-east-1"
  }
}