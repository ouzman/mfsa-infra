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

module "cognito-user-pool" {
  source = "./cognito-user-pool"
  facebook {
    client_id = var.facebook.client_id
    client_secret = var.facebook.client_secret
  }
}

module "example-lambda" {
  source = "./example-lambda"
  lambda_bucket = var.lambda_bucket
}