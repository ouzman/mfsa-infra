output "share_lambda_invoke_arn" {
    value       = aws_lambda_function.share_lambda.invoke_arn
    sensitive   = false
}

output "share_lambda_function_name" {
    value       = aws_lambda_function.share_lambda.function_name
    sensitive   = false
}
