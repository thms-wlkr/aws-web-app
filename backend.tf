provider "aws" {
  region = "eu-west-2"
}

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # backend "s3" {
  #   bucket         = "tf-state-bucket"
  #   key            = "terraform/state"
  #   region         = "eu-west-2"
  #   dynamodb_table = "terraform-lock"
  #   encrypt        = true
  # }
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "tf-state-bucket"

  tags = {
    name      = "terraform state bucket"
    terraform = "true"
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    name      = "terraform lock table"
    terraform = "true"
  }
}
