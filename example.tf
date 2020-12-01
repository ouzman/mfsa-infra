terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0ce1e3f77cd41957e"
  instance_type = "t2.micro"
}
