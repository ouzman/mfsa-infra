resource "aws_dynamodb_table" "share_table" {
  name           = "mfsa-share"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2
  write_capacity = 2
  hash_key       = "ResourceId"

  attribute {
    name = "ResourceId"
    type = "S"
  }

  ttl {
    enabled = false
  }
}
