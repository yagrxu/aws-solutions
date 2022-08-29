resource "aws_s3_bucket" "website" {
  bucket            = var.web_url
  acl               = "public-read"
  force_destroy     = true
  website {
    error_document  = "error.html"
    index_document  = "index.html"
  }
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = [var.web_url]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

data aws_route53_zone  zone{
  name         = "yagrxu.me."
  private_zone = false
}

resource "null_resource" "remove_and_upload_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${var.content_path} s3://${aws_s3_bucket.website.id} --acl public-read"
  }
}

/*resource "aws_apigatewayv2_api_mapping" "api_get_mapping" {
  api_id      = var.apigw_get_id
  domain_name = aws_apigatewayv2_domain_name.api_get_domain.id
  stage       = var.apigw_get_stage_id
}

resource "aws_apigatewayv2_domain_name" "api_get_domain" {
  domain_name = "tiny.yagrxu.me"

  domain_name_configuration {
    certificate_arn = "arn:aws:acm:eu-central-1:008810505346:certificate/0d57fc3f-b578-4a13-82dd-9bb952c5ae2b"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}*/

resource "aws_route53_record" "blog_record" {
  allow_overwrite = true
  name            = "blog.yagrxu.me"
  type            = "A"
  zone_id         = data.aws_route53_zone.zone.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_s3_bucket.website.website_domain
    zone_id                = aws_s3_bucket.website.hosted_zone_id
  }
}

/*resource "aws_route53_record" "api_get" {
  allow_overwrite = true
  name            = "tiny.yagrxu.me"
  type            = "A"
  zone_id         = data.aws_route53_zone.zone.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_apigatewayv2_domain_name.api_get_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_get_domain.domain_name_configuration[0].hosted_zone_id
  }
}*/