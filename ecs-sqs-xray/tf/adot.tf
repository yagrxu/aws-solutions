resource "aws_iam_role_policy" "adot_policy" {
  name = "${var.cluster_name}-ECS-ADOT"
  role = aws_iam_role.adot_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:PutLogEvents",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries",
          "sqs:*",
          "dynamodb:*",
          "ssm:GetParameters"
        ],
        "Resource" : "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {

  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "adot_role" {
  name                  = "${var.cluster_name}-ECS-ADOT"
  description           = "ADOT Role for ECS ADOT"
  assume_role_policy    = data.aws_iam_policy_document.ecs_assume_role_policy.json
  force_detach_policies = true
}
