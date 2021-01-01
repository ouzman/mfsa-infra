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
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": ["${var.dynamodb_share_table_arn}]"
        }
    ]
}
EOF
}

resource "aws_lambda_function" "share_lambda" {
  function_name = "mfsa-share"
  role          = aws_iam_role.share_lambda_role.arn
  handler       = "exports.handler"
  
  filename      = "files/share-lambda.zip"
  source_code_hash = data.archive_file.share_lambda_archive.output_base64sha256

  runtime = "nodejs12.x"
}