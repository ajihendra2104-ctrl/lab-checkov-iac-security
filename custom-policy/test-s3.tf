resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-custom-policy-bucket"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "insecure_bucket" {
  bucket = "my-insecure-custom-policy-bucket"
}
