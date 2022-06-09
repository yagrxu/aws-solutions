variable "role_name" {
  default = "ec2_auto_registry_role"
}
variable "profile_name" {
  default = "ec2_auto_registry_profile"
}


variable "upsert_bucket" {
  default = "yagr-demo-sg"
}

variable "upsert_object_key" {
  default = "route53-demo/upsert.json"
}

variable "local_json_file_path" {
  default = "../upsert.json"
}

variable "zone_id" {
  default = "Z00378711D58PVI3H5ZE7"
}

variable "ami" {
  default = "ami-0bd6906508e74f692"
}

variable "keypair_name" {
  default = "yagr-demo-sg"
}

variable "instance_type" {
  default = "t3.medium"
}