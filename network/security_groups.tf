# security group for public access

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
