resource "aws_ecs_cluster" "demo" {
  name = "ecs-demo"
}

# workaround for the very first time. 
# creating capacity provider will report error without a proper waiting time

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_ecs_cluster.demo]

  create_duration = "30s"
}


resource "aws_ecs_cluster_capacity_providers" "demo" {
  cluster_name = aws_ecs_cluster.demo.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  depends_on = [time_sleep.wait_30_seconds]
}

resource "aws_ecr_repository" "hello" {
  name                 = "adot-ecs-hello"
  force_delete         = true
}

resource "aws_ecr_repository" "world" {
  name                 = "adot-ecs-world"
  force_delete         = true
}

resource "aws_ecr_repository" "collector" {
  name                 = "adot-ecs-collector"
  force_delete         = true
}