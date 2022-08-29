provider "aws" {
  version = "~> 2.70.0"
}
terraform {
  backend "s3" {
    bucket = "yagr-tf-state"
    key    = "devops-demo/account_setup"
    region = "eu-central-1"
    dynamodb_table = "app-state"
  }
}

resource "aws_iam_role" "tf_role" {
  name = "TerraformRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::008810505346:root",
        "AWS": "arn:aws:iam::008810505346:user/${aws_iam_user.aad_user.name}"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
  EOF

  tags = {
    tag-key = "scope-TerraformOnly"
  }
  depends_on = [aws_iam_user.aad_user]
}

resource "aws_iam_role_policy_attachment" "tf_role_attach" {
  role       = aws_iam_role.tf_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "aad_user" {
  name = "aad_user"

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_access_key" "ak" {
  user = aws_iam_user.aad_user.name
}

resource "aws_iam_user_policy" "aad_user_policy" {
  name = "aad_policy"
  user = aws_iam_user.aad_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Resource": "arn:aws:iam::008810505346:role/TerraformRole"
  }
}
EOF
}
