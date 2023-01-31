variable "region" {
  # set default to singapore region
  default = "ap-southeast-1"
}

variable "cluster_name" {
  default = "account-a"
}

variable "private_subnets" {
  type = list(string)
  default  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type = list(string)
  default  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}



variable "seconnd_account_id" {
  default = "996599195919"
}