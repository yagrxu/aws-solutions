terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.12.0"
    }
  }
  backend "s3" {
    bucket = "yagr-tfstate-log-us"
    key    = "demo/aws-solutions/ecs-tasks"
    region = "us-east-1"
  }
}
