resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name               = "mfsa_identity_pool"
  allow_unauthenticated_identities = false

  dynamic "cognito_identity_providers" {
    for_each = var.cognito_user_pool_client_ids
    iterator = client_id
    content {
      client_id = client_id.value
      provider_name = var.cognito_user_pool_provider_name
      server_side_token_check = true
    }
  }
}