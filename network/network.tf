resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    name      = "demo-vpc"
    terraform = "true"
  }
}


resource "aws_subnet" "public_subnet" {
  for_each = var.public_subnet # create a separate aws_subnet resource for each key-value pair in the var.public_subnet variable
  vpc_id   = aws_vpc.demo_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value) # calculate the CIDR block for each subnet using the 'cidrsubnet' function; this is based off of the vpc_cidr + provides 8 subnet bits.
  availability_zone = element(data.aws_availability_zones.available.names, each.value - 1) # use the 'element' function to select an availability zone; this is sourced from a data source that retrieves the names of available availability zone/
  map_public_ip_on_launch = true #  automatically assign a public IP address to instance

  tags = {
    name      = each.key # sets the name from the current iteration of var.public_subnet
    terraform = "true"
  }
}

resource "aws_subnet" "priv_subnet_1" {
  for_each = var.private_subnet_1
  vpc_id   = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = element(data.aws_availability_zones.available.names, each.value - 1)

  tags = {
    name      = each.key
    terraform = "true"
  }
}

resource "aws_subnet" "priv_subnet_2" {
  for_each = var.private_subnet_2
  vpc_id   = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, each.value + length(var.private_subnet_1)) # ensure no overlap in CIDR mapping
  availability_zone = element(data.aws_availability_zones.available.names, each.value - 1)

  tags = {
    name      = each.key
    terraform = "true"
  }
}