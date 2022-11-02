variable "region" {
  default = "ap-southeast-1"
}

variable "cluster_name" {
  default = "devax-demo"
}

variable "grafana_endpoint" {
  description = "Grafana endpoint"
  type        = string
  default     = null
}

variable "grafana_api_key" {
  description = "API key for authorizing the Grafana provider to make changes to Amazon Managed Grafana"
  type        = string
  default     = ""
  sensitive   = true
}