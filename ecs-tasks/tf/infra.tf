module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "ecs-demo"
  cidr = "10.0.0.0/16"

  azs             = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

}

resource "aws_security_group_rule" "egress_allow_all" {
  type     = "egress"
  to_port  = 0
  protocol = "-1"
  # prefix_list_ids   = [aws_vpc_endpoint.my_endpoint.prefix_list_id]
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  security_group_id = module.vpc.default_security_group_id
}


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

resource "aws_ecr_repository" "task-demo" {
  name         = "task-demo"
  force_delete = true
}
