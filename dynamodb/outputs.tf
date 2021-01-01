output "share_table_arn" {
    value       = aws_dynamodb_table.share_table.arn
    sensitive   = false
}
