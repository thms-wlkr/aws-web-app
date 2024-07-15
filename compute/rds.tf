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
