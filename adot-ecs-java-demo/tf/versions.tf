terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7.1"
    }
    godaddy = {
      source  = "n3integration/godaddy"
      version = "1.8.7"
    }
  }
  backend "s3" {
    bucket = "yagr-tf-state-log"
    key    = "demo/aws-solutions/adot-ecs-java-demo"
    region = "us-east-1"
  }
}
