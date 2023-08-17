terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.63.0"
    }
  }

  backend "s3" {
    bucket = "yagr-tfstate-log-us"
    key    = "bigdata/emr/demo0424"
    region = "us-east-1"
  }

}
