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

resource "aws_iam_role" "authenticated_role" {
  name = "mfsa-cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.identity_pool.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated_role_policy" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Action": ["s3:ListBucket"],
      "Effect": "Allow",
      "Resource": ["${var.s3_files_bucket_arn}"],
      "Condition": {"StringLike": {"s3:prefix": ["protected/$${cognito-identity.amazonaws.com:sub}/*"]}}
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": ["${var.s3_files_bucket_arn}/protected/$${cognito-identity.amazonaws.com:sub}/*"]
    }
  ]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_pool_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    "authenticated" = aws_iam_role.authenticated_role.arn
  }
}