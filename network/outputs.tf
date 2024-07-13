output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids_1" {
  value = aws_subnet.priv_subnet_1[*].id
}

output "private_subnet_ids_2" {
  value = aws_subnet.priv_subnet_2[*].id
}

output "public_sg" {
  value = aws_security_group.public_sg.id
}

output "backend_sg" {
  value = aws_security_group.backend_sg.id
}