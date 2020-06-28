variable "name" {
  default = "wordpress"
}

variable "environment" {
  default = "dev"
}
variable "public_subnets_cidr" {
  default = ["172.16.10.0/24", "172.16.20.0/24"]
}

variable "private_subnets_cidr" {
  default = ["172.16.30.0/24", "172.16.40.0/24"]
}