output "ios_client_secret" {
    value       = aws_cognito_user_pool_client.ios_client.client_secret
    sensitive   = true
}