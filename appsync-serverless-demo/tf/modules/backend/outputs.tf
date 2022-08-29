output apigw_add_endpoint {
  value = aws_apigatewayv2_api.apigwAdd.api_endpoint
}

output apigw_get_endpoint {
  value = aws_apigatewayv2_api.apigwGet.api_endpoint
}

output apigw_get_id {
  value = aws_apigatewayv2_api.apigwGet.id
}

output apigw_get_stage_id {
  value = aws_apigatewayv2_stage.api_get_stage.id
}