resource "aws_dynamodb_table" "my_table" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "shortened-url-service"
    Environment = "staging"
  }
}

resource "aws_dynamodb_table" "counters" {
  name           = var.counters_table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "counterName"

  attribute {
    name = "counterName"
    type = "S"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  tags = {
    Name        = "id-auto-incremental-service"
    Environment = "staging"
  }
}

resource "aws_dynamodb_table_item" "example" {
  table_name = aws_dynamodb_table.counters.name
  hash_key   = aws_dynamodb_table.counters.hash_key

  item = <<ITEM
{
  "counterName": {"S": "demoCounter"},
  "currentValue": {"N": "0"}
}
ITEM
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      item,
    ]
  }
}


resource "aws_iam_role" "dynamodb_access" {
  name = "dynamodb_access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "dynamodb_access"
  role = aws_iam_role.dynamodb_access.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_dynamodb_table.my_table.arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_appsync_graphql_api" "graphql_api" {
  authentication_type = "API_KEY"
  name                = "dynamodb_demo"
  schema = var.schema
}

resource "aws_appsync_datasource" "demo" {
  api_id           = aws_appsync_graphql_api.graphql_api.id
  name             = "dynamodb_demo"
  service_role_arn = aws_iam_role.dynamodb_access.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.my_table.name
  }
}
resource "aws_appsync_api_key" "example" {
  api_id  = aws_appsync_graphql_api.graphql_api.id
  expires = "2021-05-03T04:00:00Z"
}
resource "aws_appsync_resolver" "put_resolver" {
  api_id      = aws_appsync_graphql_api.graphql_api.id
  field       = "createDemo"
  type        = "Mutation"

  data_source = aws_appsync_datasource.demo.name

  request_template = var.request_template

  response_template = var.response_template

  caching_config {
    caching_keys = [
      "$context.identity.sub",
      "$context.arguments.id"
    ]
    ttl = 60
  }
}

resource "aws_appsync_resolver" "get_resolver" {
  api_id      = aws_appsync_graphql_api.graphql_api.id
  field       = "getDemo"
  type        = "Query"

  data_source = aws_appsync_datasource.demo.name

  request_template = var.get_template

  response_template = var.response_template

  caching_config {
    caching_keys = [
      "$context.identity.sub",
      "$context.arguments.id"
    ]
    ttl = 60
  }
}