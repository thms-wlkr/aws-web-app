resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id # associate the route table with the specified VPC

  route {
    cidr_block = "0.0.0.0/0" # route for all IPv4 traffic
    gateway_id = aws_internet_gateway.internet_gw.id # igw to route traffic to the internet
  }

  tags = {
    name      = "public-route-table"
    terraform = "true" # 
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
  for_each = aws_subnet.public_subnets # iterate over each public subnet
  subnet_id = each.value.id # associate each subnet with the public route table
  route_table_id = aws_route_table.public_route_table.id # public route table id
}

locals {
  all_private_subnets = merge(aws_subnet.demo_priv_subnet_1, aws_subnet.demo_priv_subnet_2) # combine all private subnets for reference, instead of duplicating code.
}

resource "aws_route_table_association" "private" {
  for_each = local.all_private_subnets # iterate over each private subnet
  subnet_id = each.value.id # associate each subnet with the private route table
  route_table_id = aws_route_table.private_route_table.id # private route table id
}
