output api_key {
  value = aws_appsync_api_key.example.key
}

output graphql_url {
  value = aws_appsync_graphql_api.graphql_api.uris["GRAPHQL"]
}
