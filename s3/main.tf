resource "aws_s3_bucket" "files_bucket" {
  bucket = "mfsa_files_bucket"
  acl    = "private"
}