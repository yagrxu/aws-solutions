variable "region" {
  # set default to singapore region
  default = "ap-southeast-1"
}

variable "cluster_name" {
  default = "account-b"
}

variable "private_subnets" {
  type = list(string)
  default  = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
}

variable "public_subnets" {
  type = list(string)
  default  = ["192.168.101.0/24", "192.168.102.0/24", "192.168.103.0/24"]
}


variable "transit_gateway_id" {
  default = "tgw-0db4cffdf12db115d"
}

variable "resource_share_arn" {
  default = "arn:aws:ram:ap-southeast-1:613477150601:resource-share/23fb13f5-5139-45d9-bcd5-e8cd287144ce"
}