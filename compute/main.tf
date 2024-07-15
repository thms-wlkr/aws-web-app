########################################################################
####################        EC2 + ASG         ##########################
########################################################################

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
  security_groups = [var.public_sg_id]  # attach the security group, converted to set of strings
  key_name        = aws_key_pair.ec2_key.key_name  # associate the key pair
  subnet_id       = var.public_subnet_ids[0]  # launch the instance in the specified subnet
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
    security_groups = [var.public_sg_id] # attach the security group, converted to set of strings
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
    id      = aws_launch_template.web_template.id
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
    security_groups             = [var.backend_sg_id]  # security group for network access
    subnet_id                   = var.private_subnet_ids_1["priv_subnet_1a"]
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
  vpc_zone_identifier = [
    var.private_subnet_ids_1["priv_subnet_1a"],
    var.private_subnet_ids_1["priv_subnet_1b"]
  ]
  target_group_arns         = [aws_lb_target_group.alb_tg.arn]

  tag {
    key                 = "name"
    value               = "backend-instance"
    propagate_at_launch = true
  }
}

########################################################################
####################      LOAD BALANCER       ##########################
########################################################################

resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false     # whether the ALB is internal (false meaning it's internet-facing)
  load_balancer_type = "application"  # type of load balancer (application for HTTP/HTTPS)
  security_groups    = [var.public_sg_id]  # security groups associated with the ALB
  subnets = [  # list of subnets where the ALB will be deployed
    var.public_subnet_ids[0],
    var.public_subnet_ids[1]
  ]

  enable_deletion_protection = false  # disable deletion protection for the ALB (not required for this demo project)

  tags = {
    name      = "app-lb"
    terraform = "true"
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name        = "alb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  # health check configuration for the target group
  health_check {
    path                = "/"    # path used for health checks
    protocol            = "HTTP" # protocol used for health checks
    matcher             = "200"  # expected HTTP status code for a healthy instance
    interval            = 30     # interval between health checks
    timeout             = 5      # timeout for each health check attempt
    healthy_threshold   = 2      # number of consecutive successful health checks to consider an instance healthy
    unhealthy_threshold = 2      # number of consecutive failed health checks to consider an instance unhealthy
  }
}

# define a listener for the ALB to handle incoming HTTP traffic
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  # default action for the listener (forwarding traffic to the target group)
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

########################################################################
####################       RDS DATABASE       ##########################
########################################################################

resource "aws_db_instance" "rds_instance" {
  allocated_storage    = 10
  db_name              = "demo-db"
  engine               = "mysql"                     # database engine type
  engine_version       = "8.0"                       # database engine version
  instance_class       = var.rds_instance_class      # instance type for the RDS instance
  username             = "thomasdemo"
  password             = "password"
  parameter_group_name = "default.mysql8.0"          # parameter group for configuration
  skip_final_snapshot  = true                        # skip taking a final snapshot before deletion

  tags = {
    name      = "rds-instance"
    terraform = "true"
  }
}

# Define an AWS RDS subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    var.public_subnet_ids[0],
    var.private_subnet_ids_1["priv_subnet_1a"]
  ]

  tags = {
    name = "rds-subnet-group"
    terraform = "true"
  }
}
