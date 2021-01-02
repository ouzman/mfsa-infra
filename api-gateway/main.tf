data "aws_cognito_user_pools" "user_pools" {
  name = var.cognito_user_pool_name
}

resource "aws_api_gateway_authorizer" "share_api_cognito_authorizer" {
  name          = "CognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.share_api.id
  provider_arns = data.aws_cognito_user_pools.user_pools.arns
}

resource "aws_api_gateway_rest_api" "share_api" {
  name = "MFSA-Share-API"
}

resource "aws_api_gateway_method" "root_method" {
  rest_api_id   = aws_api_gateway_rest_api.share_api.id
  resource_id   = aws_api_gateway_rest_api.share_api.root_resource_id
  http_method   = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.share_api_cognito_authorizer.id
}

resource "aws_api_gateway_integration" "root_integration" {
  rest_api_id = aws_api_gateway_rest_api.share_api.id
  resource_id = aws_api_gateway_method.root_method.resource_id
  http_method = aws_api_gateway_method.root_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_share_lambda_invoke_arn
}

resource "aws_api_gateway_resource" "file_resource" {
  rest_api_id = aws_api_gateway_rest_api.share_api.id
  parent_id   = aws_api_gateway_rest_api.share_api.root_resource_id
  path_part   = "file-resource"
}


resource "aws_api_gateway_method" "file_resource_method" {
  rest_api_id = aws_api_gateway_rest_api.share_api.id
  resource_id = aws_api_gateway_resource.file_resource.id
  http_method = "GET"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.share_api_cognito_authorizer.id
}

resource "aws_api_gateway_integration" "file_resource_integration" {
  rest_api_id = aws_api_gateway_rest_api.share_api.id
  resource_id = aws_api_gateway_method.file_resource_method.resource_id
  http_method = aws_api_gateway_method.file_resource_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_share_lambda_invoke_arn
}

resource "aws_api_gateway_resource" "specific_file_resource" {
  rest_api_id = aws_api_gateway_rest_api.share_api.id
  parent_id   = aws_api_gateway_resource.file_resource.id
  path_part   = "{resource}"
}

resource "aws_api_gateway_resource" "specific_file_resource_identity" {
  rest_api_id = aws_api_gateway_rest_api.share_api.id
  parent_id   = aws_api_gateway_resource.specific_file_resource.id
  path_part   = "identity"
}

resource "aws_api_gateway_method" "specific_file_resource_identity_method" {
  rest_api_id = aws_api_gateway_rest_api.share_api.id
  resource_id = aws_api_gateway_resource.specific_file_resource_identity.id
  http_method = "PUT"

  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.share_api_cognito_authorizer.id

  request_parameters = {
    "method.request.path.resource" = true
  }
}

resource "aws_api_gateway_integration" "specific_file_resource_identity_integration" {
  rest_api_id = aws_api_gateway_rest_api.share_api.id
  resource_id = aws_api_gateway_method.specific_file_resource_identity_method.resource_id
  http_method = aws_api_gateway_method.specific_file_resource_identity_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_share_lambda_invoke_arn
}


resource "aws_api_gateway_deployment" "share_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.root_integration,
    aws_api_gateway_integration.file_resource_integration,
    aws_api_gateway_integration.specific_file_resource_identity_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.share_api.id
  stage_name  = "default"
}

resource "aws_lambda_permission" "share_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_share_lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.share_api.execution_arn}/*/*"
}
