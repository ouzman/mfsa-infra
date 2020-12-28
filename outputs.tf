output "cognito_user_pool_ios_client_secret" {
    value       = module.cognito_user_pool.ios_client_secret
    sensitive   = true
}