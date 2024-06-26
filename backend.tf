terraform {
  backend "s3" {
    bucket = "demo-bucket"  // Replace with your bucket name
    key    = "terraform.tfstate"
    region = "eu-west-1"  // Replace with your preferred AWS region
  }
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "demo-bucket"
  acl    = "private" # Note: This will still work, but it's deprecated

  tags = {
    name      = "tf-state-bucket"
    terraform = true
  }
}