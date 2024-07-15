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
