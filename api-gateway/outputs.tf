output "base_url" {
  value = aws_api_gateway_deployment.share_api_deployment.invoke_url
}