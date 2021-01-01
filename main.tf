terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.00"
    }
  }
}

locals {
  cognito_user_pool_name = "mfsa-user-pool"
}

provider "aws" {
  profile = "default"
  region  = var.region
}

provider "archive" {}

module "s3" {
  source = "./s3"
}

module "cognito_user_pool" {
  source = "./cognito-user-pool"
  facebook = {
    client_id = var.facebook_client_id
    client_secret = var.facebook_client_secret
  }
  cognito_user_pool_name = local.cognito_user_pool_name
}

module "cognito_identity_pool" {
  source = "./cognito-identity-pool"
  cognito_user_pool_provider_name = module.cognito_user_pool.user_pool_endpoint
  cognito_user_pool_client_ids = [ module.cognito_user_pool.ios_client_id ]
  s3_files_bucket_arn = module.s3.files_bucket_arn
}

module "dynamodb" {
  source = "./dynamodb"
}

module "lambda" {
  source = "./lambda"
  dynamodb_share_table_arn = module.dynamodb.share_table_arn 
}

module "api_gateway" {
  source = "./api-gateway"
  lambda_share_lambda_invoke_arn = module.lambda.share_lambda_invoke_arn
  lambda_share_lambda_function_name = module.lambda.share_lambda_function_name
  cognito_user_pool_name = local.cognito_user_pool_name
  depends_on = [ module.lambda ]
}