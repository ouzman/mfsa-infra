output "cognito_user_pool_ios_client_id" {
    value       = module.cognito_user_pool.ios_client_id
    sensitive   = false
}

output "cognito_user_pool_ios_client_secret" {
    value       = module.cognito_user_pool.ios_client_secret
    sensitive   = false
}

output "cognito_user_pool_endpoint" {
    value       = module.cognito_user_pool.user_pool_endpoint
    sensitive   = false
}