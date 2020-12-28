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

module "cognito_identity_pool" {
  source = "./cognito-identity-pool"
  cognito_user_pool_provider_name = module.cognito_user_pool.user_pool_endpoint
  cognito_user_pool_client_ids = [ module.cognito_user_pool.ios_client_id ]
}

module "example_lambda" {
  source = "./example-lambda"
  lambda_bucket = var.lambda_bucket
}