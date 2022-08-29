output api_key {
  value = module.storage.api_key
}

output graphql_url {
  value = module.storage.graphql_url
}

output apigw_add_endpoint {
  value = module.backend.apigw_add_endpoint
}

output apigw_get_endpoint {
  value = module.backend.apigw_get_endpoint
}
