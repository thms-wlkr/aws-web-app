########################################################################
####################       VPC + SUBNETS      ##########################
########################################################################

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    name      = "demo-vpc"
    terraform = "true"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public_subnet" {
  for_each = var.public_subnet # create a separate aws_subnet resource for each key-value pair in the var.public_subnet variable
  vpc_id   = aws_vpc.vpc.id
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

########################################################################
####################      SECURITY GROUPS      #########################
########################################################################

resource "aws_security_group" "public_sg" {
  name        = "allow http/https"
  description = "allow traffic on port 80 and 443" 
  vpc_id      = aws_vpc.vpc.id # VPC id where the security group will be created

  tags = {
    name      = "public-SG"
    terraform = "true"
  }

  # inbound rule to allow HTTP traffic
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # allow traffic from any IP address
  }

  # inbound rule to allow HTTPS traffic
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound rule to allow SSH traffic
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound rule to allow all traffic
  egress {
    description = "Allow all traffic" 
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# this security group is for backend instances that need to communicate with public-facing instances.
# it allows SSH and HTTP traffic from the public security group and all ICMP traffic from anywhere.

resource "aws_security_group" "backend_sg" {
  name        = "backend-SG"
  description = "security group for internal instance communication" 
  vpc_id      = aws_vpc.vpc.id # VPC id where the security group will be created

  tags = {
    name      = "backend-SG"
    terraform = "true"
  }

  # inbound rule to allow SSH traffic from the public security group
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id] # allow traffic from the public security group
  }

  # inbound rule to allow HTTP traffic from the public security group
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }

  # inbound rule to allow all ICMP traffic (ping) from anywhere
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound rule to allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################################################
####################       NAT GW + IGW       ##########################
########################################################################

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id  # associate the internet gateway with the specified VPC

  tags = {
    name      = "igw"
    terraform = "true"
  }
}

resource "aws_eip" "nat_gateway_eip_1" {
  domain = "vpc"                      # allocate the elastic ip in the vpc context

  tags = {
    name      = "gateway-eip-1"
    terraform = "true"
  }
}

resource "aws_eip" "nat_gateway_eip_2" {
  domain = "vpc"                      # allocate the elastic ip in the vpc context

  tags = {
    name      = "gateway-eip-2"
    terraform = "true"
  }
}

resource "aws_nat_gateway" "nat_gateway_1" {
  allocation_id = aws_eip.nat_gateway_eip_1.id  # use the first allocated EIP for the NAT gateway
  subnet_id     = aws_subnet.public_subnet["pub_subnet_1"].id  # place the NAT gateway in the first public subnet

  tags = {
    name = "nat-gw-1"
  }
}

resource "aws_nat_gateway" "nat_gateway_2" {
  allocation_id = aws_eip.nat_gateway_eip_2.id  # use the second allocated EIP for the NAT hateway
  subnet_id     = aws_subnet.public_subnet["pub_subnet_2"].id  # place the NAT gateway in the second public subnet

  tags = {
    name = "nat-gw-2"
  }
}

########################################################################
####################       ROUTE TABLES       ##########################
########################################################################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id # associate the route table with the specified VPC

  route {
    cidr_block = "0.0.0.0/0" # route for all IPv4 traffic
    gateway_id = aws_internet_gateway.internet_gw.id # igw to route traffic to the internet
  }

  tags = {
    name      = "public-route-table"
    terraform = "true"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id # associate the route table with the specified VPC

  route {
    cidr_block     = "0.0.0.0/0" # route for all IPv4 traffic
    nat_gateway_id = aws_nat_gateway.nat_gateway_1.id # NAT gateway to route traffic to the internet through NAT
  }

  tags = {
    name      = "private-route-table"
    terraform = "true"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public_subnet # iterate over each public subnet
  subnet_id = each.value.id # associate each subnet with the public route table
  route_table_id = aws_route_table.public_route_table.id # public route table id
}

locals {
  all_private_subnets = merge(aws_subnet.priv_subnet_1, aws_subnet.priv_subnet_2) # combine all private subnets for reference, instead of duplicating code.
}

resource "aws_route_table_association" "private" {
  for_each = local.all_private_subnets # iterate over each private subnet
  subnet_id = each.value.id # associate each subnet with the private route table
  route_table_id = aws_route_table.private_route_table.id # private route table id
}


