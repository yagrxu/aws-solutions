terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.8.0"
    }
  }
  backend "s3" {
    bucket = "yagr-tf-state-log"
    key    = "solutions/ec2-monitor"
    region = "us-east-1"
  }
}

resource "aws_cloudwatch_event_rule" "ec2_state" {
  name        = "ec2-state-change"
  description = "capture ec2 state change"

  event_pattern = <<EOF
    {
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
        "state": ["stopped", "running", "terminated"]
    }
    }
EOF
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda_ec2_monitor"

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

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging_ec2_monitor"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Resource": "*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_lambda_function" "ec2_state_handler" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "archive.zip"
  function_name = "ec2_monitor"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  # source_code_hash = filebase64sha256("archive.zip")

  runtime = "python3.9"
  environment {
    variables = {
      GLOBAL_AWS_ACCESS_KEY_ID = var.access_key_id,
      GLOBAL_AWS_SECRET_ACCESS_KEY = var.secret_access_key,
      EC2_TAG_KEY = var.ec2_tag_key,
      EC2_TAG_VALUE = var.ec2_tag_value
    }
  }
}

resource "aws_cloudwatch_event_target" "check_at_rate" {
  rule = aws_cloudwatch_event_rule.ec2_state.name
  arn = aws_lambda_function.ec2_state_handler.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_state_handler.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.ec2_state.arn
}