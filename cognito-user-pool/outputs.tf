output "ios_client_id" {
    value       = aws_cognito_user_pool_client.ios_client.id
    sensitive   = false
}

output "ios_client_secret" {
    value       = aws_cognito_user_pool_client.ios_client.client_secret
    sensitive   = false
}

output "user_pool_endpoint" {
    value       = aws_cognito_user_pool.user_pool.endpoint
    sensitive   = false
}