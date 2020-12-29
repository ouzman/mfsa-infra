resource "aws_s3_bucket" "files_bucket" {
  bucket = "mfsa-files"
  acl    = "private"
}