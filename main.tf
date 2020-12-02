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
  region  = var.region
}

module "cognito" {
  source = "./cognito"
  facebook_appid = var.facebook_appid
}

module "example-lambda" {
  source = "./example-lambda"
  bucket_name = var.bucket_name
}