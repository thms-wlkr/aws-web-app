terraform {
  backend "s3" {
    bucket = "your-state-file-bucket"
    key = "project-infrastrcture"
    region = "us-east-1"
  }
}