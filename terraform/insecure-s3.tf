resource "aws_s3_bucket" "public_test" {
  bucket = "my-insecure-public-test-bucket"
  acl    = "public-read"
}
