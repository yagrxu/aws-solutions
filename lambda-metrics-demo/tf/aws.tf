terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
  backend "s3" {
    bucket = "yagr-tfstate-log-us"
    key    = "tfc/observability/lambda-otel-demo"
    region = "us-east-1"
  }
}

resource "aws_lambda_function" "metrics-demo" {
  filename      = "metrics-demo.zip"
  function_name = "metrics-demo"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  timeout       = 10
  source_code_hash = filebase64sha256("metrics-demo.zip")
  runtime = "python3.9"
  vpc_config {
    subnet_ids = split(",", var.subnets)
    security_group_ids = var.sg_ids
  }
#   tracing_config {
#     mode = "Active"
#   }
  environment {
    variables = {
      COLLECTOR_URL     = "test"
    }
  }
}



resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_otel_metrics"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}