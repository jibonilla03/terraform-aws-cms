//VPC variables

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

// EC2 Variables

variable "key_name" {
  default = "tendo"
}

variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDKYGh4gggsnnFDUa4msTi5qyI0gNMCL/ULbLcM6FaihpJY4tJY3K3vGl1LWZRWTTm+BChyEqvZEo+VcFDlKL1FzLPBRk5loCEQljhNbqks7rg3iQyTDXRH7NaMwkfKPxzlkVKJovHxJsERgdiEqNT2ckksvtNPwkxxMD8TRtvZMp+KaYIjf2oC6Va52sD0kn2xpSARjFnUdWxrJxQptNxDJs4Yc/fkwF7al9yLvyWdC1ZcqdmKQ6hou+X1HurSVbUjhV3sZ5ppNK84pLjAOnvKsaGTgCL7BW6jDRC8O1y3qH5cdBVpqPEphz43Llu+5SupQRiUBSJ/60EQmtrt8LjZyVNFx67PCwc/uZlDT0aTVkJGmt4s56HUPJSkT4ymz00dlfhFZ7MkJKkewneXiBjalM7ezWitWNqWzaW6EcEzRe20XVNPO3/D+Ogp4oJRTw5m1nXwwthCCefZrB2yO473tcLezIZlHtSzW9d550ik1PwfanKWU8vtb9nCUVoskOE= jbonilla@LAPTOP-HVS3AD1I"
}

variable "ami_id" {
  default = "ami-f95ef58a"
}

variable "instance_type" {
  description = "Type of instance"
  default     = "t2.nano"
}

variable "instance_count" {
  description = "Number of instance(s) to be launched"
  default     = 2
}

variable "ebs_root_volume_type" {
  default = "gp2"
}

variable "ebs_root_volume_size" {
  default = "8"
}

variable "ebs_root_delete_on_termination" {
  default = true
}

variable "server_role" {
  default = "test"
}

variable "user_data" {
  description = "User data that need to pass to the instance(s)"
  default     = "#!/bin/bash\napt-get -y update\napt-get -y install nginx\n"
}

// RDS variables

variable "storage" {
  description = "Storage size in GB"
  default     = "5"
}

variable "engine" {
  description = "Engine type, example values mysql, postgres"
  default     = "mysql"
}

variable "engine_version" {
  description = "Engine version"
  default     = "5.7"
}

variable "instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "multi_az" {
  description = "Multi-AZ or not"
  default     = false
}

variable "db_name" {
  default     = "testdb"
  description = "db name"
}

variable "username" {
  default     = "root"
  description = "User name"
}

variable "password" {
  description = "password, provide through your ENV variables"
}

// DNS Route53 variables
/*variable "domain_name" {
  default = "yourcustomdomain.net"
}*/


