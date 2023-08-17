
resource "aws_s3_bucket" "uploads" {
  bucket        = "yagr-uploads"
  force_destroy = true
}

resource "aws_cloudwatch_event_target" "uploads" {
  target_id = "yagr-process-uploads"
  arn       = aws_ecs_cluster.demo.arn
  rule      = aws_cloudwatch_event_rule.uploads.name
  role_arn  = aws_iam_role.uploads_events.arn
  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.task.arn

    network_configuration {
      subnets = module.vpc.private_subnets
      # assign_public_ip = true
    }
  }
  input_transformer {
    # This section plucks the values we need from the event
    input_paths = {
      s3_bucket = "$.detail.requestParameters.bucketName"
      s3_key    = "$.detail.requestParameters.key"
    }
    # This is the input template for the ECS task. The variables
    # defined in input_path above are available. This passes the 
    # bucket name and object key as environment variables to the
    # task
    input_template = <<TEMPLATE
{
  "containerOverrides": [
    {
      "name": "task-demo",
      "environment": [
        { "name": "S3_BUCKET", "value": <s3_bucket> },
        { "name": "S3_KEY", "value": <s3_key> }
      ]
    }
  ]
}
TEMPLATE
  }
}

resource "aws_cloudwatch_event_rule" "uploads" {
  name          = "yagr-capture-uploads"
  description   = "Capture S3 events on uploads bucket"
  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject",
      "CompleteMultipartUpload"
    ],
    "requestParameters": {
      "bucketName": [
        "${aws_s3_bucket.uploads.id}"
      ]
    }
  }
}
PATTERN
}

resource "aws_ecs_task_definition" "task" {
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  family                   = "task"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_role.arn
  task_role_arn            = aws_iam_role.ecs_role.arn
  container_definitions = jsonencode([
    {
      name  = "task-demo"
      image = "613477150601.dkr.ecr.ap-southeast-1.amazonaws.com/task-demo:v0.1"
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-create-group  = "true",
          awslogs-group         = "/ecs/fargate-task-definition",
          awslogs-region        = "ap-southeast-1",
          awslogs-stream-prefix = "ecs"
        }
      }
      essential = true
    }
  ])
}
