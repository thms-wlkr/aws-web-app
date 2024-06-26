output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids_1" {
  value = aws_subnet.demo_priv_subnet_1[*].id
}

output "private_subnet_ids_2" {
  value = aws_subnet.demo_priv_subnet_2[*].id
}

output "ec2_instance_id" {
  value = aws_instance.web_server.id
}

output "lb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
