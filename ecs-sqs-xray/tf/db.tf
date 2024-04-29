resource "aws_dynamodb_table" "apm_test_table" {
  #checkov:skip=CKV2_AWS_16:demo only, autoscaling is not needed
  #checkov:skip=CKV_AWS_119:demo only, no encryption is needed

  name           = "${var.cluster_name}-demo"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  point_in_time_recovery {
   enabled = true
  }

  attribute {
    name = "id"
    type = "S"
  }

}