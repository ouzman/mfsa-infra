data "archive_file" "share_lambda_archive" {
  type        = "zip"
  source_file = "${path.module}/share-lambda.js"
  output_path = "${path.module}/files/share-lambda.zip"
}

resource "aws_iam_role" "share_lambda_role" {
  name = "mfsa_share_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "share_lambda_policy" {
  name        = "mfsa_share_lambda_policy"
  role        =  aws_iam_role.share_lambda_role.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
      ],
      "Resource": [
          "arn:aws:dynamodb:eu-west-1:315952967095:table/mfsa-share"
          "arn:aws:logs:*:*:*",
      ]
      "Effect": "Allow"
    },
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "share_lambda" {
  function_name = "mfsa-share"
  role          = aws_iam_role.share_lambda_role.arn
  handler       = "share-lambda.handler"
  
  filename      = "${path.module}/files/share-lambda.zip"
  source_code_hash = data.archive_file.share_lambda_archive.output_base64sha256

  runtime = "nodejs12.x"
}