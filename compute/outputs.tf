output "ec2_instance_id" {
  value = aws_instance.web_server.id
}

output "lb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
