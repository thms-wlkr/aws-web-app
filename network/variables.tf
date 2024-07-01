variable "vpc_cidr" {
  description = "the default CIDR for VPC."
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  description = "mapping of public subnets with their respective identifiers."
  default = {
    "pub_subnet_1" = 1
    "pub_subnet_2" = 2

  }
}

variable "private_subnet_1" {
  description = "mapping of private subnets with their respective identifiers."
  default = {
    "priv_subnet_1a" = 3
    "priv_subnet_1b" = 4
  }
}

variable "private_subnet_2" {
  description = "mapping of private subnets with their respective identifiers."
  default = {
    "priv_subnet_2a" = 5
    "priv_subnet_2b" = 6
  }
}