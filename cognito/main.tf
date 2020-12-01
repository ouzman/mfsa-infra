resource "aws_cognito_identity_pool" "main_pool" {
  identity_pool_name               = "mfsa_identity_pool"
  allow_unauthenticated_identities = false

  supported_login_providers = {
    "graph.facebook.com" = var.facebook_appid
  }
}

resource "aws_iam_role" "authenticated_role" {
  name = "mfsa_identity_pool_authenticated_role"

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
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main_pool.id}"
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

resource "aws_iam_role" "unauthenticated_role" {
  name = "mfsa_identity_pool_unauthenticated_role"

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
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.main_pool.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "unauthenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated_role_policy" {
  name = "mfsa_identity_pool_authenticated_role_policy"
  role = aws_iam_role.authenticated_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "unauthenticated_role_policy" {
  name = "mfsa_identity_pool_unauthenticated_role_policy"
  role = aws_iam_role.unauthenticated_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "main_pool_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.main_pool.id

  roles = {
    "authenticated" = aws_iam_role.authenticated_role.arn
    "unauthenticated" = aws_iam_role.authenticated_role.arn
  }
}