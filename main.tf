terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.00"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.region
}

module "cognito_user_pool" {
  source = "./cognito-user-pool"
  facebook = {
    client_id = var.facebook_client_id
    client_secret = var.facebook_client_secret
  }
}

module "example_lambda" {
  source = "./example-lambda"
  lambda_bucket = var.lambda_bucket
}