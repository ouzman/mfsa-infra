resource "aws_cognito_user_pool" "main_user_pool" {
  name                      = "mfsa_main_user_pool"
  alias_attributes          = "email"
  auto_verified_attributes  = [ "email" ]
  mfa_configuration         = "OFF"
  account_recovery_setting {
    recovery_mechanism {
      name      = "admin_only"
      priority  = 1
    }
  }
  username_configuration {
    case_sensitive  = false
  }
  admin_create_user_config {
    allow_admin_create_user_only  = true
  }
}

resource "aws_cognito_user_pool_client" "ios_client" {
  name              = "mfsa-ios-client"
  user_pool_id      = aws_cognito_user_pool.main_user_pool.id
  generate_secret   = true
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
  supported_identity_providers = { "facebook" }
  logout_urls = { "mfsaios://" }
  callback_urls = { "mfsaios://" }
  default_redirect_uri = "mfsaios://"
  allowed_oauth_scopes = { "email", "openid" }
}

output "ios-client-secret" {
  value = aws_cognito_user_pool_client.ios_client.client_secret
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "mfsa-user"
  user_pool_id = aws_cognito_user_pool.main_user_pool.id
}

resource "aws_cognito_identity_provider" "facebook_provider" {
  user_pool_id  = aws_cognito_user_pool.main_user_pool.id
  provider_name = "facebook"
  provider_type = "Facebook"

  provider_details = {
    authorize_scopes = "email"
    client_id        = var.facebook.client_id
    client_secret    = var.facebook.client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }
}