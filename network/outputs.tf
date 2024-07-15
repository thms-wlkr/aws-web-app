output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = [for _, subnet in aws_subnet.public_subnet : subnet.id] # iterates over each subnet in aws_subnet.public_subnet, extracting the id attribute
}

output "private_subnet_ids_1" {
  value = { for k, v in aws_subnet.priv_subnet_1 : k => v.id } # constructs a key-value pair where the key is k (the subnet name) and the value is v.id (the ID of the subnet)
}

output "private_subnet_ids_2" {
  value = { for k, v in aws_subnet.priv_subnet_2 : k => v.id }
}

output "public_sg" {
  value = aws_security_group.public_sg.id
}

output "backend_sg" {
  value = aws_security_group.backend_sg.id
}