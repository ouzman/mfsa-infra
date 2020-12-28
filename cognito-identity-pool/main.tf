resource "aws_cognito_user_pool" "user_pool" {
  name                      = "mfsa_user_pool"
  alias_attributes          = [ "email" ]
  auto_verified_attributes  = [ "email" ]
  mfa_configuration         = "OFF"
  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
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
  name                                  = "mfsa-ios-client"
  user_pool_id                          = aws_cognito_user_pool.main_user_pool.id
  generate_secret                       = true
  allowed_oauth_flows_user_pool_client  = true
  allowed_oauth_flows                   = [ "code", "implicit" ]
  explicit_auth_flows                   = [ "ADMIN_NO_SRP_AUTH" ]
  supported_identity_providers          = [ "Facebook" ]
  logout_urls                           = [ "mfsaios://" ]
  callback_urls                         = [ "mfsaios://" ]
  default_redirect_uri                  = "mfsaios://"
  allowed_oauth_scopes                  = [ "email", "openid" ]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "mfsa-user"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

resource "aws_cognito_identity_provider" "facebook_provider" {
  user_pool_id  = aws_cognito_user_pool.user_pool.id
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details = {
    authorize_scopes = "email"
    client_id        = var.facebook.client_id
    client_secret    = var.facebook.client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "id"
  }
}