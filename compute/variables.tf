variable "ami_id" {
  description = "AMI id for EC2 instances"
  default     = "ami-04ff98ccbfa41c9ad"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "name for the EC2 key pair"
  default     = "ec2_key"
}

variable "private_key_path" {
  description = "path to save the private key"
  default     = "/c/Users/twalker/.ssh/ec2_key.pem"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into instances"
  default     = "0.0.0.0/0" # can replace with a specific IP or range for better security
}

variable "rds_instance_class" {
  description = "The instance class for the DB instance"
  default     = "db.t3.micro"
}