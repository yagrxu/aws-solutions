provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name     = replace(basename(path.cwd), "-cluster", "")
  region   = "ap-southeast-1"
  key_name = "yagr-demo-sg"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = { Example = local.name
    GithubRepo = "terraform-aws-emr"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# EMR Module
################################################################################

# data "template_file" "cluster_1_configuration" {
#   template = file("${path.module}/templates/configuration.json.tpl")
# }


module "emr_cluster" {
  source  = "terraform-aws-modules/emr/aws"
  version = "1.0.0"

  name = "yagr-demo"

  release_label_filters = {
    emr6 = {
      prefix = "emr-6.8.0"
    }
  }
  applications = ["Hadoop", "Spark", "Hive", "Hue", "Livy", "Oozie", "Pig", "Tez", "JupyterEnterpriseGateway", "JupyterHub", "Zeppelin", "Presto"]
  auto_termination_policy = {
    idle_timeout = 21600
  }

  bootstrap_action = {
    example = {
      name = "Just an example",
      path = "file:/bin/echo",
      args = ["Hello World!"]
    }
  }
  configurations_json = jsonencode([
    {
      "Classification" : "spark-env",
      "Configurations" : [
        {
          "Classification" : "export",
          "Properties" : {
            "JAVA_HOME" : "/usr/lib/jvm/java-1.8.0"
          }
        }
      ],
      "Properties" : {}
      }, {
      "Classification" : "hive-site",
      "Properties" : {
        "hive.metastore.client.factory.class" : "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
      }

      }, {
      "Classification" : "spark-hive-site",
      "Properties" : {
        "hive.metastore.client.factory.class" : "com.amazonaws.glue.catalog.metastore.AWSGlueDataCatalogHiveClientFactory"
      }
      }, {
      "Classification" : "presto-connector-hive",
      "Properties" : {
        "hive.metastore.glue.datacatalog.enabled" : "true"
      }
    }
  ])

  master_instance_group = {
    name           = "master-group"
    instance_count = 1
    instance_type  = "m5.xlarge"
  }

  core_instance_group = {
    name           = "core-group"
    instance_count = 1
    instance_type  = "c4.xlarge"
  }

  task_instance_group = {
    name           = "task-group"
    instance_count = 2
    instance_type  = "m5.xlarge"
    # bid_price      = "0.1"

    ebs_config = {
      size                 = 64
      type                 = "gp3"
      volumes_per_instance = 1
    }
    ebs_optimized = true
  }

  ebs_root_volume_size = 64
  ec2_attributes = {
    # Instance groups only support one Subnet/AZ
    subnet_id = element(module.vpc.public_subnets, 0)
    key_name  = local.key_name
  }
  vpc_id = module.vpc.vpc_id
  # Required for creating public cluster
  is_private_cluster = false

  keep_job_flow_alive_when_no_steps = true
  list_steps_states                 = ["PENDING", "RUNNING", "CANCEL_PENDING", "CANCELLED", "FAILED", "INTERRUPTED", "COMPLETED"]
  log_uri                           = "s3://${module.s3_bucket.s3_bucket_id}/"

  scale_down_behavior    = "TERMINATE_AT_TASK_COMPLETION"
  step_concurrency_level = 3
  termination_protection = false
  visible_to_all_users   = true

  tags = local.tags
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = local.vpc_cidr

  azs            = local.azs
  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

  enable_nat_gateway   = false
  enable_dns_hostnames = true

  # https://docs.aws.amazon.com/emr/latest/ManagementGuide/emr-managed-iam-policies.html#manually-tagged-resources
  # Tag if you want EMR to create the security groups for you
  # vpc_tags            = { "for-use-with-amazon-emr-managed-policies" = true }
  # Tag if you are using public subnets
  public_subnet_tags = { "for-use-with-amazon-emr-managed-policies" = true }
  # Tag if you are using private subnets
  # private_subnet_tags = { "for-use-with-amazon-emr-managed-policies" = true }

  tags = local.tags
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> v3.0"

  bucket_prefix = "${local.name}-"

  # Allow deletion of non-empty bucket
  # Example usage only - not recommended for production
  force_destroy = true

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}
