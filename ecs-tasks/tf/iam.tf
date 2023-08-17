resource "aws_iam_role" "uploads_events" {
  name               = "yagr-uploads-events"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy" "ecs_events_run_task_with_any_role" {
  name   = "yagr-uploads-run-task-with-any-role"
  role   = aws_iam_role.uploads_events.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ecs:RunTask",
      "Resource": "${replace(aws_ecs_task_definition.task.arn, "/:\\d+$/", ":*")}"
    }
  ]
}
POLICY
}

data "aws_iam_policy_document" "ecs_assume_role_policy" {

  statement {
    sid = "EKSFargateAssumeRole"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ecs_policy" {
  name = "yagr-uploads-execution"
  role = aws_iam_role.ecs_role.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:*",
          "s3:*",
          "ecr:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_role" {
  name                  = "yagr-uploads-execution"
  description           = "Role for ECS"
  assume_role_policy    = data.aws_iam_policy_document.ecs_assume_role_policy.json
  force_detach_policies = true
}
