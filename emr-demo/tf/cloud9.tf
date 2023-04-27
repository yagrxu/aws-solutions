resource "aws_cloud9_environment_ec2" "working-env" {
  instance_type = "m5.large"
  name          = "emr-demo"
  subnet_id     = element(module.vpc.public_subnets, 0)
  owner_arn     = var.owner_arn
}
