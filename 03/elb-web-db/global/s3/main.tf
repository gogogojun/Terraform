provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "myTFState" {
  bucket        = "bucket-gjh-98585488"
  force_destroy = true

  tags = {
    Name = "My Bucket Terraform state"
  }
}


resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.myTFState.id
  versioning_configuration {
    status = "Enabled"
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.myTFState.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "restricted" {
  bucket                  = aws_s3_bucket.myTFState.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "myTFLocks" {
  name         = "myTFLocks-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}