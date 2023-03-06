variable "subnets" {
  default = "subnet-095e1f001ca96beab,subnet-0bebdd599a6954360,subnet-066f0bac4984fe7cc"
}

variable "sg_ids" {
  type = list
  default= ["sg-00ec3564be375a973", "sg-01dd055e228fc97f9"]
}