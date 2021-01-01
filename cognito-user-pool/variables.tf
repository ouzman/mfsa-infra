variable "facebook" {
  type = object({
    client_id = string
    client_secret = string
  })
}

variable "cognito_user_pool_name" {
  type = string
}