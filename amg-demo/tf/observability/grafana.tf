
resource "aws_grafana_workspace" "example" {
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  role_arn                 = aws_iam_role.assume.arn
  vpc_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }
}

resource "aws_grafana_role_association" "example" {
  role         = "ADMIN"
  user_ids     = var.user_ids
  workspace_id = aws_grafana_workspace.example.id
}

resource "aws_iam_role" "assume" {
  name = "${var.cluster_name}-grafana-assume"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "Prometheus"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

}
