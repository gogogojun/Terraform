provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_s3_bucket" "example" {
  bucket = "qwea123lsdliko"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}