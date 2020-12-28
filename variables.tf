variable "region" {
  type = string
}

variable "lambda_bucket" {
    type = string
}

variable "facebook" {
  type = object({
    client_id = string
    client_secret = string
  })
}