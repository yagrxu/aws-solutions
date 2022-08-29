locals {
  file_name = "index.zip"
}

provider archive{}
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir = "../../lambda/demo"
  output_path = local.file_name
}
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "lambda" {
  filename      = local.file_name
  function_name = "demo"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  timeout       = 10
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "nodejs12.x"

  environment {
    variables = {
      API_KEY     = var.api_key
      API_URL     = var.api_url
      DOMAIN_NAME = "tiny.yagrxu.me"
    }
  }
  provisioner "local-exec" {
    command = "rm ./${local.file_name}"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_dynamodb.arn
}

resource "aws_iam_policy" "lambda_dynamodb" {
  name        = "lambda_dynamodb"
  path        = "/"
  description = "IAM policy for dynamodb"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ReadWriteTable",
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:GetItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWriteItem",
                "dynamodb:PutItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": [
              "arn:aws:dynamodb:*:*:table/${var.table_name}",
              "arn:aws:dynamodb:*:*:table/${var.counters_table_name}"
              ]
        },
        {
            "Sid": "GetStreamRecords",
            "Effect": "Allow",
            "Action": "dynamodb:GetRecords",
            "Resource": [
              "arn:aws:dynamodb:*:*:table/${var.table_name}/stream/* ",
              "arn:aws:dynamodb:*:*:table/${var.counters_table_name}"
            ]
        },
        {
            "Sid": "WriteLogStreamsAndGroups",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Sid": "CreateLogGroup",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role" "iam_for_apigw" {
  name = "iam_for_apigw"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apigw_policy_attach" {
  role       = aws_iam_role.iam_for_apigw.name
  policy_arn = aws_iam_policy.apigw_policies.arn
}

resource "aws_iam_policy" "apigw_policies" {
  name        = "apigw_lambda"
  path        = "/"
  description = "IAM policy for lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "GetStreamRecords",
            "Effect": "Allow",
            "Action": [
              "lambda:*"
            ],
            "Resource": [
              "arn:aws:lambda:eu-central-1:008810505346:function:demo"
            ]
        }
    ]
}
EOF
}


resource "aws_apigatewayv2_api" "apigwAdd" {
  name          = "demoAdd"
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = false
    allow_headers     = [
      "*",
    ]
    allow_methods     = [
      "GET",
      "POST",
    ]
    allow_origins     = [
      "*",
    ]
    expose_headers    = [
      "*",
    ]
    max_age           = 2
  }
}

resource "aws_apigatewayv2_integration" "integrationAdd" {
  api_id                    = aws_apigatewayv2_api.apigwAdd.id
  integration_type          = "AWS_PROXY"
  description               = "DemoAdd"
  integration_method        = "POST"
  payload_format_version    = "2.0"
  integration_uri           = aws_lambda_function.lambda.invoke_arn
  credentials_arn           = aws_iam_role.iam_for_apigw.arn
}


resource "aws_apigatewayv2_route" "routeAdd" {
  api_id    = aws_apigatewayv2_api.apigwAdd.id
  route_key = "POST /"
  target    = "integrations/${aws_apigatewayv2_integration.integrationAdd.id}"
}

resource "aws_apigatewayv2_deployment" "deploymentAdd" {
  api_id      = aws_apigatewayv2_api.apigwAdd.id
  description = "deployment"
  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_apigatewayv2_integration.integrationAdd),
      jsonencode(aws_apigatewayv2_route.routeAdd),
    )))
  }
}

resource "aws_apigatewayv2_stage" "demo_stage" {
  api_id      = aws_apigatewayv2_api.apigwAdd.id
  name        = "$default"
  auto_deploy = true
}
# second API GW
resource "aws_apigatewayv2_api" "apigwGet" {
  name          = "demoGet"
  protocol_type = "HTTP"
  cors_configuration {
    allow_credentials = false
    allow_headers     = [
      "*",
    ]
    allow_methods     = [
      "GET",
      "POST",
    ]
    allow_origins     = [
      "*",
    ]
    expose_headers    = [
      "*",
    ]
    max_age           = 2
  }
}

resource "aws_apigatewayv2_integration" "integrationGet" {
  api_id                    = aws_apigatewayv2_api.apigwGet.id
  integration_type          = "AWS_PROXY"
  description               = "Demo"
  integration_method        = "POST"
  payload_format_version    = "2.0"
  integration_uri           = aws_lambda_function.lambda.invoke_arn
  credentials_arn           = aws_iam_role.iam_for_apigw.arn
}

resource "aws_apigatewayv2_route" "routeGet" {
  api_id    = aws_apigatewayv2_api.apigwGet.id
  route_key = "GET /{url}"
  target    = "integrations/${aws_apigatewayv2_integration.integrationGet.id}"
}

resource "aws_apigatewayv2_deployment" "deploymentGet" {
  api_id      = aws_apigatewayv2_api.apigwGet.id
  description = "deployment"
  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_apigatewayv2_integration.integrationGet),
      jsonencode(aws_apigatewayv2_route.routeGet),
    )))
  }
}


resource "aws_apigatewayv2_stage" "api_get_stage" {
  api_id = aws_apigatewayv2_api.apigwGet.id
  name   = "$default"
  auto_deploy = true
}