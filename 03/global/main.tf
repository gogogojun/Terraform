resource "aws_s3_bucket" "my_terraform_state" {
  bucket = "bucket-gjh-0416"
  force_destroy = true
  
  tags = {
    Name = "My S3 bucket"
  }
}

resource "aws_s3_bucket_versioning" "my_s3_bucket_version" {
  bucket = aws_s3_bucket.my_terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_s3_bucket_enc" {
  bucket = aws_s3_bucket.my_terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}