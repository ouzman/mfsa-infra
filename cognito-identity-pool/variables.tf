variable "cognito_user_pool_provider_name" {
  type = string
}

variable "cognito_user_pool_client_ids" {
  type = set(string)
}

variable "s3_files_bucket_arn" {
  type = string
}