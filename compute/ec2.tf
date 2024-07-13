# generate a private key using the RSA algorithm
resource "tls_private_key" "key_gen" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# create an EC2 key pair using the public key from the generated private key
resource "aws_key_pair" "ec2_key" {
  key_name   = var.key_name
  public_key = tls_private_key.key_gen.public_key_openssh
}

# save the generated private key to a local file for SSH access
resource "local_file" "private_key" {
  content  = tls_private_key.key_gen.private_key_pem
  filename = var.private_key_path
}

resource "aws_instance" "web_server" {
  instance_type   = var.instance_type  # the type of instance to launch
  ami             = var.ami_id  # AMI id to use for the instance
  security_groups = var.public_sg_id  # attach the security group
  key_name        = aws_key_pair.ec2_key.key_name  # associate the key pair
  subnet_id       = aws_subnet.public_subnets["pub_subnet_1a"].id  # launch the instance in the specified subnet
  user_data       = base64encode(file("userdata.sh"))  # provide user data script

  tags = {
    name      = "web-server"
    terraform = "true"
  }
}

# launch template for EC2 instances
resource "aws_launch_template" "web_template" {
  name_prefix   = "app-"  # prefix for the launch template name
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2_key.key_name

  network_interfaces {
    security_groups = var.public_sg_id # attach the security group
  }

  user_data = base64encode(file("userdata.sh"))  # provide user data script

  tag_specifications {
    resource_type = "instance"
    tags = {
      name      = "web-server"
      terraform = "true"
    }
  }
}

# create an auto scaling group
resource "aws_autoscaling_group" "web_asg" {
  name                = "web_asg"
  desired_capacity    = 1  # desired number of instances
  max_size            = 2  # max number of instances
  min_size            = 1  # min number of instances
  vpc_zone_identifier = var.public_subnet_ids  # subnets for the asg

  launch_template {
    id      = aws_launch_template.web_server_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.alb_tg.arn]  # attach to the specified target group

  tag {
    key                 = "name"
    value               = "asg-web-server"
    propagate_at_launch = true  # propagate this tag to instances launched by the asg
  }
}

# define a target tracking scaling policy for the auto scaling group
resource "aws_autoscaling_policy" "target_tracking_policy" {
  name                      = "target_tracking_policy" 
  policy_type               = "TargetTrackingScaling"  # asg will adjust its capacity to maintain a target metric value
  adjustment_type           = "ChangeInCapacity"  # add or remove instances based on the scaling policy
  estimated_instance_warmup = 300  # estimated time until a newly launched instance can contribute to metrics
  autoscaling_group_name    = aws_autoscaling_group.web_asg.name  # Name of the Auto Scaling Group

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"  # predefined metric for tracking CPU utilization
    }
    target_value = 50.0  # asg will strive to maintain this metric by scaling instances in or out as needed
  }
}

# define a launch template for backend instances
resource "aws_launch_template" "backend_template" {
  name_prefix   = "backend-"
  image_id      = var.ami_id 
  instance_type = var.instance_type
  key_name      = aws_key_pair.ec2_key.key_name

  network_interfaces {
    associate_public_ip_address = false # do not assign public IP addresses
    security_groups             = var.backend_sg_id  # security group for network access
    subnet_id                   = aws_subnet.private_subnet_1["priv_subnet_1a"].id
  }

  tag_specifications {
    resource_type = "instance"  # type of resource to tag
    tags = {
      Name      = "backend-instance"
      Terraform = "true"
    }
  }
}

# define an asg for the backend instances
resource "aws_autoscaling_group" "backend_asg" {
  name                      = "backend-asg"
  launch_template {
    id      = aws_launch_template.backend_template.id
    version = "$Latest"
  }
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 3
  vpc_zone_identifier       = [aws_subnet.private_subnets_1["priv_subnet_1a"].id]
  target_group_arns         = [aws_lb_target_group.alb_tg.arn]

  tag {
    key                 = "name"
    value               = "backend-instance"
    propagate_at_launch = true
  }
}
