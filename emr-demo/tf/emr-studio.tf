resource "aws_emr_studio" "demo" {
  auth_mode                   = "IAM"
  default_s3_location         = "s3://${aws_s3_bucket.studio-s3.bucket}/"
  engine_security_group_id    = aws_security_group.engine.id
  name                        = "demo"
  service_role                = data.aws_iam_role.studio_role.arn
  subnet_ids                  = module.vpc.public_subnets
  vpc_id                      = module.vpc.vpc_id
  workspace_security_group_id = aws_security_group.workspace.id
}

resource "aws_security_group" "engine" {
  name        = "engine"
  description = "engine"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_security_group" "workspace" {
  name        = "workspace"
  description = "workspace"
  vpc_id      = module.vpc.vpc_id

}

resource "aws_security_group_rule" "engine_ingress" {
  type                     = "ingress"
  from_port                = 18888
  to_port                  = 18888
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.workspace.id
  security_group_id        = aws_security_group.engine.id
}

resource "aws_security_group_rule" "workspace_egress" {
  type                     = "egress"
  from_port                = 18888
  to_port                  = 18888
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.engine.id
  security_group_id        = aws_security_group.workspace.id
}

data "aws_iam_role" "studio_role" {
  name = "EMR_Notebooks_DefaultRole"
}

data "aws_security_group" "master_nodes_sg" {
  id = module.emr_cluster.managed_master_security_group_id
}

resource "aws_security_group_rule" "ssh_ingress_master" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = data.aws_security_group.master_nodes_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
