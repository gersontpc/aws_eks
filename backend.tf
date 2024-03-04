# Backend
terraform {
  backend "s3" {
    bucket = "223341017520-tfstate"
    key    = "479610723/gson-labs-new.tfvars"
    region = "us-east-1"
  }
}