data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.0"

  name = "ecs-java-demo"
  cidr = "10.0.0.0/16"

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
}

resource "aws_ecs_cluster" "demo" {
  name = var.cluster_name
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
  name         = "${var.cluster_name}-hello"
  force_delete = true
}

resource "aws_ecr_repository" "world" {
  name         = "${var.cluster_name}-world"
  force_delete = true
}

resource "aws_ecr_repository" "collector" {
  name         = "${var.cluster_name}-ecs-collector"
  force_delete = true
}
